
-- define some basic home components
local lang = vRP.lang
local sanitizes = require("resources/vrp/cfg/sanitizes")

-- CHEST

local function chest_create(owner_id, stype, sid, config, x, y, z, player)
  local chest_enter = function(player,area)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and user_id == owner_id then
      vRP.openChest(player, "u"..owner_id.."home", config.weight or 200,nil,nil,nil)
    end
  end


  local chest_leave = function(player,area)
    vRP.closeMenu(player)
  end

  local nid = "vRP:home:slot"..stype..sid..":chest"
  vRPclient.setNamedMarker(player,{nid,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})
  vRP.setArea(player,nid,x,y,z,1,1.5,chest_enter,chest_leave)
end

local function chest_destroy(owner_id, stype, sid, config, x, y, z, player)
  local nid = "vRP:home:slot"..stype..sid..":chest"
  vRPclient.removeNamedMarker(player,{nid})
  vRP.removeArea(player,nid)
end

vRP.defHomeComponent("chest", chest_create, chest_destroy)

-- WARDROBE

local function wardrobe_create(owner_id, stype, sid, config, x, y, z, player)
  local wardrobe_enter = function(player,area)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and user_id == owner_id then
      -- notify player if wearing a uniform
      local data = vRP.getUserDataTable(user_id)
      if data.cloakroom_idle ~= nil then
        vRPclient.notify(player,{lang.common.wearing_uniform()})
      end

      -- build menu
      local menu = {name=lang.home.wardrobe.title(),css={top = "75px", header_color="rgba(0,255,125,0.75)"}}

      -- load sets
      local sets = json.decode(vRP.getUData(user_id,"vRP:home:wardrobe"))
      if sets == nil then
        sets = {}
      end

      -- save
      menu[lang.home.wardrobe.save.title()] = {function(player, choice)
        vRP.prompt(player, lang.home.wardrobe.save.prompt(), "", function(player, setname)
          setname = sanitizeString(setname, sanitizes.text[1], sanitizes.text[2])
          if string.len(setname) > 0 then
            -- save custom
            vRPclient.getCustomization(player,{},function(custom)
              sets[setname] = custom
              -- save to db
              vRP.setUData(user_id,"vRP:home:wardrobe",json.encode(sets))

              -- actualize menu
              wardrobe_enter(player, area)
            end)
          else
            vRPclient.notify(player,{lang.common.invalid_value()})
          end
        end)
      end}

      local choose_set = function(player,choice)
        local custom = sets[choice]
        if custom ~= nil then
          vRPclient.setCustomization(player,{custom})
        end
      end

      -- sets
      for k,v in pairs(sets) do
        menu[k] = {choose_set}
      end

      -- open the menu
      vRP.openMenu(player,menu)
    end
  end

  local wardrobe_leave = function(player,area)
    vRP.closeMenu(player)
  end

  local nid = "vRP:home:slot"..stype..sid..":wardrobe"
  vRPclient.setNamedMarker(player,{nid,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})
  vRP.setArea(player,nid,x,y,z,1,1.5,wardrobe_enter,wardrobe_leave)
end

local function wardrobe_destroy(owner_id, stype, sid, config, x, y, z, player)
  local nid = "vRP:home:slot"..stype..sid..":wardrobe"
  vRPclient.removeNamedMarker(player,{nid})
  vRP.removeArea(player,nid)
end

vRP.defHomeComponent("wardrobe", wardrobe_create, wardrobe_destroy)
