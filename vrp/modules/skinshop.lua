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
local function menu_skinshop_part(self)
  local function update_part(menu, part)
    -- apply change
    local custom = {}
    local data = {menu.drawable[1],menu.texture[1],menu.palette and menu.palette[1]}
    custom[part] = data
    menu.data.custom[part] = data -- update current menu customization
    vRP.EXT.PlayerState.remote.setCustomization(menu.user.source,custom)
  end

  local function m_model(menu, value, mod, index)
    local user = menu.user
    local part = menu.data.part
    local drawable = menu.drawable
    local texture = menu.texture

    local isprop = SkinShop.parsePart(part)

    -- change drawable
    drawable[1] = drawable[1]+mod

    if isprop then
      if drawable[1] >= drawable[2] then drawable[1] = -1 -- circular selection (-1 for prop parts)
      elseif drawable[1] < -1 then drawable[1] = drawable[2]-1 end 
    else
      if drawable[1] >= drawable[2] then drawable[1] = 0 -- circular selection
      elseif drawable[1] < 0 then drawable[1] = drawable[2]-1 end 
    end

    menu:updateOption(index, nil, lang.skinshop.select_description({drawable[1]+1,drawable[2]}))

    -- update max textures
    texture[2] = vRP.EXT.PlayerState.remote.getDrawableTextures(user.source,part,drawable[1])

    if texture[1] >= texture[2] then texture[1] = 0 -- circular selection
    elseif texture[1] < 0 then texture[1] = texture[2]-1 end 

    menu:updateOption(index+1, nil, lang.skinshop.select_description({texture[1]+1,texture[2]}))

    update_part(menu, part)
  end

  local function m_texture(menu, value, mod, index)
    local user = menu.user
    local part = menu.data.part
    local texture = menu.texture

    -- change texture
    texture[1] = texture[1]+mod

    if texture[1] >= texture[2] then texture[1] = 0 -- circular selection
    elseif texture[1] < 0 then texture[1] = texture[2]-1 end 

    menu:updateOption(index, nil, lang.skinshop.select_description({texture[1]+1,texture[2]}))

    update_part(menu, part)
  end

  local function m_palette(menu, value, mod, index)
    local user = menu.user
    local part = menu.data.part
    local palette = menu.palette

    -- change palette
    palette[1] = palette[1]+mod

    if palette[1] >= palette[2] then palette[1] = 0 -- circular selection
    elseif palette[1] < 0 then palette[1] = palette[2]-1 end 

    menu:updateOption(index, nil, lang.skinshop.select_description({palette[1]+1,palette[2]}))

    update_part(menu, part)
  end

  vRP.EXT.GUI:registerMenuBuilder("skinshop.part", function(menu)
    local user = menu.user

    menu.title = menu.data.title
    menu.css.header_color="rgba(0,255,125,0.75)"

    local part = menu.data.part
    local isprop, index = SkinShop.parsePart(part)

    local current_part = menu.data.custom[part]

    menu.drawable = {current_part and current_part[1] or 0, vRP.EXT.PlayerState.remote.getDrawables(user.source, part)}
    menu.texture = {current_part and current_part[2] or 0, vRP.EXT.PlayerState.remote.getDrawableTextures(user.source, part, menu.drawable[1])}

    if not isprop then
      menu.palette = {current_part and current_part[3] or 2, 4}
    end

    menu:addOption(lang.skinshop.model(), m_model, lang.skinshop.select_description({menu.drawable[1], menu.drawable[2]}))
    menu:addOption(lang.skinshop.texture(), m_texture, lang.skinshop.select_description({menu.texture[1], menu.texture[2]}))
    if not isprop then 
      menu:addOption(lang.skinshop.palette(), m_palette, lang.skinshop.select_description({menu.palette[1], menu.palette[2]}))
    end
  end)
end

-- menu: shinshop
local function menu_skinshop(self)
  -- return price of customization changes
  local function compute_price(menu)
    -- compute price
    local price = 0
    for k,v in pairs(menu.custom) do
      local old = menu.old_custom[k]
      if v[1] ~= old[1] then price = price+self.cfg.drawable_change_price end -- change of drawable
      if v[2] ~= old[2] then price = price+self.cfg.texture_change_price end -- change of texture
    end

    return price
  end

  local function close(menu) -- menu closed
    local user = menu.user

    local price = compute_price(menu)

    if price > 0 then
      if user:tryPayment(price) then
        vRP.EXT.Base.remote._notify(user.source,lang.money.paid({price}))
      else
        vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
        -- revert changes
        vRP.EXT.PlayerState.remote._setCustomization(user.source, menu.old_custom)
      end
    end
  end

  local function m_part(menu, title)
    local smenu = menu.user:openMenu("skinshop.part", {
      title = title, 
      part = menu.data.parts[title], 
      custom = menu.custom
    })

    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  vRP.EXT.GUI:registerMenuBuilder("skinshop", function(menu)
    local user = menu.user

    menu.title = lang.skinshop.title()
    menu.css.header_color="rgba(0,255,125,0.75)"

    if not menu.old_custom then -- first time opening the menu
      -- notify player if wearing a uniform
      if user:hasCloak() then
        vRP.EXT.Base.remote._notify(user.source,lang.common.wearing_uniform())
      end

      -- get old customization to compute the price
      menu.old_custom = vRP.EXT.PlayerState.remote.getCustomization(menu.user.source)
      menu.old_custom.modelhash = nil

      menu.custom = clone(menu.old_custom) -- current customization state
    end

    menu:addOption(lang.skinshop.info.title(), nil, lang.skinshop.info.description({compute_price(menu)}))

    -- parts
    for title,part in pairs(menu.data.parts) do
      menu:addOption(title, m_part, nil, title)
    end

    menu:listen("remove", close)
  end)
end

-- METHODS

function SkinShop:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/skinshops")
  self:log(#self.cfg.skinshops.." skinshops")

  menu_skinshop_part(self)
  menu_skinshop(self)
end

-- EVENT

SkinShop.event = {}

function SkinShop.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- init skinshops
    for k,v in pairs(self.cfg.skinshops) do
      local cfg,x,y,z = table.unpack(v)

      local menu
      local function enter(user)
        menu = user:openMenu("skinshop", {parts = cfg.parts})
      end

      local function leave(user)
        user:closeMenu(menu)
      end

      local ment = clone(cfg.map_entity)
      ment[2].title = lang.skinshop.title()
      ment[2].pos = {x,y,z-1}
      vRP.EXT.Map.remote._addEntity(user.source, ment[1], ment[2])

      user:setArea("vRP:skinshop:"..k,x,y,z,1,1.5,enter,leave)
    end
  end
end

vRP:registerExtension(SkinShop)
