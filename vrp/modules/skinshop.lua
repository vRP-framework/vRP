local lang = vRP.lang

-- a basic skinshop implementation
local SkinShop = class("SkinShop", vRP.Extension)

-- STATIC

-- parse part key (a ped part or a prop part)
-- return is_proppart, index
function SkinShop.parsePart(key)
  if type(key) == "string" and string.sub(key,1,1) == "p" then
    return true,tonumber(string.sub(key,2))
  else
    return false,tonumber(key)
  end
end

-- PRIVATE METHODS

-- menu: shinshop
local function menu_skinshop(self)
  local function close(menu) -- menu closed
    local user = menu.user

    -- compute price
    local custom = vRP.EXT.PlayerState.remote.getCustomization(user.source)
    local price = 0
    custom.modelhash = nil
    for k,v in pairs(custom) do
      local old = menu.old_custom[k]
      if v[1] ~= old[1] then price = price+self.cfg.drawable_change_price end -- change of drawable
      if v[2] ~= old[2] then price = price+self.cfg.texture_change_price end -- change of texture
    end

    if user:tryPayment(price) then
      if price > 0 then
        vRP.EXT.Base.remote._notify(user.source,lang.money.paid({price}))
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
      -- revert changes
      vRP.EXT.PlayerState.remote._setCustomization(user.source, old_custom)
    end
  end

  local function m_part(menu, part, mod)
    local user = menu.user
    local drawable = menu.drawables[part]

    if mod == 0 then -- texture select
      -- change texture
      drawable[3] = drawable[3]+1
      if drawable[3] >= drawable[4] then drawable[3] = 0 end -- circular selection

      -- apply change
      local custom = {}
      custom[part] = {drawable[1],drawable[3]}
      vRP.EXT.PlayerState.remote._setCustomization(user.source,custom)
    else -- drawable select
      local isprop, index = SkinShop.parsePart(part)

      -- change drawable
      drawable[1] = drawable[1]+mod

      if isprop then
        if drawable[1] >= drawable[2] then drawable[1] = -1 -- circular selection (-1 for prop parts)
        elseif drawable[1] < -1 then drawable[1] = drawable[2]-1 end 
      else
        if drawable[1] >= drawable[2] then drawable[1] = 0 -- circular selection
        elseif drawable[1] < 0 then drawable[1] = drawable[2] end 
      end

      -- apply change
      local custom = {}
      custom[part] = {drawable[1],drawable[3]}
      vRP.EXT.PlayerState.remote.setCustomization(user.source,custom)

      -- update max textures
      drawable[4] = vRP.EXT.PlayerState.remote.getDrawableTextures(user.source,part,drawable[1])
      if drawable[3] >= drawable[4] then
        drawable[3] = 0 -- reset texture number
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("skinshop", function(menu)
    menu.title = lang.skinshop.title()
    menu.css.header_color="rgba(0,255,125,0.75)"

    --[[
    -- notify player if wearing a uniform
    local data = vRP.getUserDataTable(user_id)
    if data.cloakroom_idle ~= nil then
      vRPclient._notify(source,lang.common.wearing_uniform())
    end
    --]]

    -- get old customization to compute the price
    menu.old_custom = vRP.EXT.PlayerState.remote.getCustomization(menu.user.source)
    menu.old_custom.modelhash = nil
    menu.drawables = {} -- map of part => {dcurrent, dmax, tcurrent, tmax}

    -- parts
    for title,part in pairs(menu.data.parts) do
      menu:addOption(title, m_part, nil, part)

      -- initilize drawable selection
      local drawable = {0,0,0,0}
      local old_part = menu.old_custom[part]
      if old_part then
        drawable[1], drawable[3] = old_part[1], old_part[3]
      end

      -- init max drawables and max textures
      drawable[2] = vRP.EXT.PlayerState.remote.getDrawables(menu.user.source, part)
      drawable[4] = vRP.EXT.PlayerState.remote.getDrawableTextures(menu.user.source, part, drawable[1])

      menu.drawables[part] = drawable
    end

    menu:listen("close", close)
  end)
end

-- METHODS

function SkinShop:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/skinshops")
  self:log(#self.cfg.skinshops.." skinshops")

  menu_skinshop(self)
end

-- EVENT

SkinShop.event = {}

function SkinShop.event:playerSpawn(user, first_spawn)
  if first_spawn then
    for k,v in pairs(self.cfg.skinshops) do
      local parts,x,y,z = table.unpack(v)

      local menu
      local function enter(user)
        menu = user:openMenu("skinshop", {parts = parts})
      end

      local function leave(user)
        user:closeMenu(menu)
      end

      vRP.EXT.Map.remote._addBlip(user.source,x,y,z,73,3,lang.skinshop.title())
      vRP.EXT.Map.remote._addMarker(user.source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)

      user:setArea("vRP:skinshop"..k,x,y,z,1,1.5,enter,leave)
    end
  end
end

vRP:registerExtension(SkinShop)
