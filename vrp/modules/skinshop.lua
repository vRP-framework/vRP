-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.skinshop then return end
  
local lang = vRP.lang

-- a basic skinshop implementation
local SkinShop = class("SkinShop", vRP.Extension)

-- PRIVATE METHODS

-- menu: shinshop
local function menu_skinshop_part(self)
  local function update_part(menu, part)
    -- apply change
    local custom = {}
    local data
    local args = splitString(part, ":")

    if args[1] == "prop" or args[1] == "drawable" then
      data = {menu.drawable[1],menu.texture[1],menu.palette and menu.palette[1]}
    elseif args[1] == "overlay" then
      data = {menu.overlay[1], menu.overlay[2], menu.overlay[3], menu.overlay[4]}
    elseif args[1] == "hair_color" then
      data = {menu.hair_color[1], menu.hair_color[2]}
    end

    custom[part] = data
    menu.data.custom[part] = data -- update current menu customization
    vRP.EXT.PlayerState.remote.setCustomization(menu.user.source,custom)
  end

  local function m_model(menu, value, mod, index)
    local user = menu.user
    local part = menu.data.part
    local drawable = menu.drawable
    local texture = menu.texture

    local args = splitString(part, ":")

    -- change drawable
    drawable[1] = drawable[1]+mod

    if args[1] == "prop" then
      if drawable[1] >= drawable[2] then drawable[1] = -1 -- circular selection (-1 for prop parts)
      elseif drawable[1] < -1 then drawable[1] = drawable[2]-1 end 
    elseif args[1] == "drawable" then
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

  local function m_hair_color(menu, value, mod, index)
    local user = menu.user
    local part = menu.data.part
    local hair_color = menu.hair_color

    -- change hair color
    hair_color[value] = hair_color[value]+mod

    if hair_color[value] >= 64 then hair_color[value] = 0 -- circular selection
    elseif hair_color[value] < 0 then hair_color[value] = 64-1 end 

    menu:updateOption(index, nil, lang.skinshop.select_description({hair_color[value]+1,64}))

    update_part(menu, part)
  end

  local function m_overlay_model(menu, value, mod, index)
    local user = menu.user
    local part = menu.data.part
    local overlay = menu.overlay
    local overlay_count = menu.overlay_count

    local overlay_value = overlay[1]
    if overlay_value == 255 then overlay_value = -1 end

    -- change overlay
    overlay_value = overlay_value+mod

    if overlay_value >= overlay_count then overlay_value = -1 -- circular selection
    elseif overlay_value < -1 then overlay_value = overlay_count-1 end 

    menu:updateOption(index, nil, lang.skinshop.select_description({overlay_value+1,overlay_count}))

    -- change real overlay
    overlay[1] = (overlay_value == -1 and 255 or overlay_value)

    update_part(menu, part)
  end

  local function m_overlay_color(menu, value, mod, index)
    local user = menu.user
    local part = menu.data.part
    local overlay = menu.overlay

    local cindex = value+1

    -- change overlay color
    overlay[cindex] = overlay[cindex]+mod

    if overlay[cindex] >= 64 then overlay[cindex] = 0 -- circular selection
    elseif overlay[cindex] < 0 then overlay[cindex] = 64-1 end 

    menu:updateOption(index, nil, lang.skinshop.select_description({overlay[cindex]+1,64}))

    update_part(menu, part)
  end

  local function m_overlay_opacity(menu, value, mod, index)
    local user = menu.user
    local part = menu.data.part
    local overlay = menu.overlay

    local opacity_value = math.floor(overlay[4]*10)-1

    -- change opacity
    opacity_value = opacity_value+mod

    if opacity_value >= 10 then opacity_value = -1 -- circular selection
    elseif opacity_value < -1 then opacity_value = 10-1 end 

    menu:updateOption(index, nil, lang.skinshop.select_description({opacity_value+1,10}))

    overlay[4] = (opacity_value+1)/10

    update_part(menu, part)
  end

  vRP.EXT.GUI:registerMenuBuilder("skinshop.part", function(menu)
    local user = menu.user

    menu.title = menu.data.title
    menu.css.header_color="rgba(0,255,125,0.75)"

    local part = menu.data.part
    local args = splitString(part, ":")

    local current_part = menu.data.custom[part]

    if args[1] == "prop" or args[1] == "drawable" then -- prop, drawable
      menu.drawable = {current_part and current_part[1] or 0, vRP.EXT.PlayerState.remote.getDrawables(user.source, part)}
      menu.texture = {current_part and current_part[2] or 0, vRP.EXT.PlayerState.remote.getDrawableTextures(user.source, part, menu.drawable[1])}

      if args[1] == "drawable" then
        menu.palette = {current_part and current_part[3] or 2, 4}
      end

      menu:addOption(lang.skinshop.model(), m_model, lang.skinshop.select_description({menu.drawable[1]+1, menu.drawable[2]}))
      menu:addOption(lang.skinshop.texture(), m_texture, lang.skinshop.select_description({menu.texture[1]+1, menu.texture[2]}))
      if args[1] == "drawable" then
        menu:addOption(lang.skinshop.palette(), m_palette, lang.skinshop.select_description({menu.palette[1]+1, menu.palette[2]}))
      end
    elseif args[1] == "overlay" then -- overlay
      menu.overlay = {current_part and current_part[1] or 255, current_part and current_part[2] or 0, current_part and current_part[3] or 0, current_part and current_part[4] or 1.0}
      menu.overlay_count = vRP.EXT.PlayerState.remote.getDrawables(user.source, part)

      local overlay_value = menu.overlay[1]
      if overlay_value == 255 then overlay_value = -1 end

      menu:addOption(lang.skinshop.model(), m_overlay_model, lang.skinshop.select_description({overlay_value+1, menu.overlay_count}))
      menu:addOption(lang.skinshop.color_primary(), m_overlay_color, lang.skinshop.select_description({menu.overlay[2]+1, 64}), 1)
      menu:addOption(lang.skinshop.color_secondary(), m_overlay_color, lang.skinshop.select_description({menu.overlay[3]+1, 64}), 2)
      local opacity_value = math.floor(menu.overlay[4]*10)-1
      menu:addOption(lang.skinshop.opacity(), m_overlay_opacity, lang.skinshop.select_description({opacity_value+1, 10}))
    elseif args[1] == "hair_color" then -- hair_color
      menu.hair_color = {current_part and current_part[1] or 0, current_part and current_part[2] or 0}

      menu:addOption(lang.skinshop.color_primary(), m_hair_color, lang.skinshop.select_description({menu.hair_color[1]+1, 64}), 1)
      menu:addOption(lang.skinshop.color_secondary(), m_hair_color, lang.skinshop.select_description({menu.hair_color[2]+1, 64}), 2)
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
      local args = splitString(k, ":")
      local old = menu.old_custom[k] or {}

      if args[1] == "drawable" or args[1] == "prop" then
        if v[1] ~= old[1] then price = price+self.cfg.drawable_change_price end
        if v[2] ~= old[2] then price = price+self.cfg.texture_change_price end
      elseif args[1] == "hair_color" then
        for i=1,2 do
          if v[i] ~= old[i] then price = price+self.cfg.color_change_price end
        end
      elseif args[1] == "overlay" then
        if v[1] ~= old[1] then price = price+self.cfg.drawable_change_price end

        for i=2,4 do
          if v[i] ~= old[i] then price = price+self.cfg.color_change_price end
        end
      end
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

  local function m_part(menu, idx)
    local entry = menu.data.parts[idx]

    local smenu = menu.user:openMenu("skinshop.part", {
      title = entry[1],
      part = entry[2], 
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
    for idx, entry in ipairs(menu.data.parts) do
      menu:addOption(entry[1], m_part, nil, idx)
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
