
-- cloakroom system
local lang = vRP.lang
local cfg = module("cfg/cloakrooms")

-- build cloakroom menus

local menus = {}

-- save idle custom (return current idle custom copy table)
local function save_idle_custom(player, custom)
  local r_idle = {}

  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local data = vRP.getUserDataTable(user_id)
    if data then
      if data.cloakroom_idle == nil then -- set cloakroom idle if not already set
        data.cloakroom_idle = custom
      end

      -- copy custom
      for k,v in pairs(data.cloakroom_idle) do
        r_idle[k] = v
      end
    end
  end

  return r_idle
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

  -- check if not uniform cloakroom
  local not_uniform = false
  if v._config and v._config.not_uniform then not_uniform = true end

  -- choose cloak 
  local choose = function(player, choice)
    local custom = v[choice]
    if custom then
      vRPclient.getCustomization(player,{},function(custom)
        local idle_copy = {}

        if not not_uniform then -- if a uniform cloakroom
          -- save old customization if not already saved (idle customization)
          idle_copy = save_idle_custom(player, custom)
        end

        -- prevent idle_copy to hide the cloakroom model property (modelhash priority)
        if v[choice].model ~= nil then
          idle_copy.modelhash = nil
        end

        -- write on idle custom copy
        for l,w in pairs(v[choice]) do
          idle_copy[l] = w
        end

        -- set cloak customization
        vRPclient.setCustomization(player,{idle_copy})
      end)
    end
  end

  -- rollback clothes
  if not not_uniform then
    menu[lang.cloakroom.undress.title()] = {function(player,choice) rollback_idle_custom(player) end}
  end

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
        if user_id ~= nil and vRP.hasPermissions(user_id,gcfg.permissions or {}) then
          if gcfg.not_uniform then -- not a uniform cloakroom
            -- notify player if wearing a uniform
            local data = vRP.getUserDataTable(user_id)
            if data.cloakroom_idle ~= nil then
              vRPclient.notify(source,{lang.common.wearing_uniform()})
            end
          end

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


