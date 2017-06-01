
-- cloakroom system
local lang = vRP.lang
local cfg = require("resources/vrp/cfg/cloakrooms")

-- build cloakroom menus

local menus = {}

local function save_idle_custom(player, custom)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local data = vRP.getUserDataTable(user_id)
    if data then
      if data.cloakroom_idle == nil then -- set cloakroom idle if not already set
        data.cloakroom_idle = custom
      end
    end
  end
end

local function rollback_idle_custom(player)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local data = vRP.getUserDataTable(user_id)
    if data then
      if data.cloakroom_idle ~= nil then -- consume cloakroom idle
        vRPclient.setCustomization(player,{data.cloakroom_idle})
        data.cloakroom_idle = nil
      end
    end
  end
end

for k,v in pairs(cfg.cloakroom_types) do
  local menu = {name=lang.cloakroom.title({k}),css={top="75px",header_color="rgba(0,125,255,0.75)"}}
  menus[k] = menu

  -- choose cloak 
  local choose = function(player, choice)
    local custom = v[choice]
    if custom then
      vRPclient.getCustomization(player,{},function(custom)
        custom.model = nil
        custom.modelhash = nil
        -- save old customization if not already saved (idle customization)
        save_idle_custom(player, custom)

        -- set cloak customization
        vRPclient.setCustomization(player,{v[choice]})
      end)
    end
  end

  -- rollback clothes
  menu[lang.cloakroom.undress.title()] = {function(player,choice) rollback_idle_custom(player) end}

  -- add cloak choices
  for l,w in pairs(v) do
    if l ~= "_config" then
      menu[l] = {choose}
    end
  end
end

-- clients points

local function build_client_points(source)
  for k,v in pairs(cfg.cloakrooms) do
    local gtype,x,y,z = table.unpack(v)
    local cloakroom = cfg.cloakroom_types[gtype]
    local menu = menus[gtype]
    if cloakroom and menu then
      local gcfg = cloakroom._config or {}

      local function cloakroom_enter(source,area)
        local user_id = vRP.getUserId(source)
        if user_id ~= nil and (gcfg.permission == nil or vRP.hasPermission(user_id,gcfg.permission)) then
          vRP.openMenu(source,menu)
        end
      end

      local function cloakroom_leave(source,area)
        vRP.closeMenu(source)
      end

      -- cloakroom
      vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,125,255,125,150})
      vRP.setArea(source,"vRP:cfg:cloakroom"..k,x,y,z,1,1.5,cloakroom_enter,cloakroom_leave)
    end
  end
end

-- add points on first spawn
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    build_client_points(source)
  end
end)


