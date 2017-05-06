-- a basic garage implementation

-- vehicle db
local q_init = vRP.sql:prepare([[
CREATE TABLE IF NOT EXISTS vrp_user_vehicles(
  user_id INTEGER,
  vehicle VARCHAR(255),
  CONSTRAINT pk_user_vehicles PRIMARY KEY(user_id,vehicle),
  CONSTRAINT fk_user_vehicles_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);
]])
q_init:execute()

local q_add_vehicle = vRP.sql:prepare("INSERT IGNORE INTO vrp_user_vehicles(user_id,vehicle) VALUES(@user_id,@vehicle)")
local q_get_vehicles = vRP.sql:prepare("SELECT vehicle FROM vrp_user_vehicles WHERE user_id = @user_id")

-- load config

local cfg = require("resources/vrp/cfg/garages")
local vehicle_groups = cfg.garage_types

local garages = cfg.garages

-- garage menus

local garage_menus = {}

for group,vehicles in pairs(vehicle_groups) do
  local veh_type = vehicles._config.vtype or "default"

  local menu = {
    name="Garage ("..group..")",
    css={top = "75px", header_color="rgba(255,125,0,0.75)"}
  }
  garage_menus[group] = menu

  menu["Owned"] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
      -- build nested menu
      local kitems = {}
      local submenu = {name="Garage (owned)", css={top="75px",header_color="rgba(255,125,0,0.75)"}}
      submenu.onclose = function()
        vRP.openMenu(player,menu)
      end

      local choose = function(player, choice)
        local vname = kitems[choice]
        if vname then
          -- spawn vehicle
          local vehicle = vehicles[vname]
          if vehicle then
            vRP.closeMenu(player)
            vRPclient.spawnGarageVehicle(player,{veh_type,vname})
          end
        end
      end
      
      -- get player owned vehicles
      q_get_vehicles:bind("@user_id",user_id)
      local pvehicles = q_get_vehicles:query():toTable()

      for k,v in pairs(pvehicles) do
        local vehicle = vehicles[v.vehicle]
        if vehicle then
          submenu[vehicle[1]] = {choose,vehicle[3]}
          kitems[vehicle[1]] = v.vehicle
        end
      end

      vRP.openMenu(player,submenu)
    end
  end,"Owned vehicles."}

  menu["Buy"] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
      -- build nested menu
      local kitems = {}
      local submenu = {name="Garage (buy)", css={top="75px",header_color="rgba(255,125,0,0.75)"}}
      submenu.onclose = function()
        vRP.openMenu(player,menu)
      end

      local choose = function(player, choice)
        local vname = kitems[choice]
        if vname then
          -- buy vehicle
          local vehicle = vehicles[vname]
          if vehicle and vRP.tryPayment(user_id,vehicle[2]) then
            q_add_vehicle:bind("@user_id",user_id)
            q_add_vehicle:bind("@vehicle",vname)
            q_add_vehicle:execute()

            vRPclient.notify(player,{"Paid "..vehicle[2].." $"})
            vRP.closeMenu(player)
          else
            vRPclient.notify(player,{"You don't have enough money."})
          end
        end
      end
      
      -- get player owned vehicles (indexed by vehicle type name in lower case)
      q_get_vehicles:bind("@user_id",user_id)
      local _pvehicles = q_get_vehicles:query():toTable()
      local pvehicles = {}
      for k,v in pairs(_pvehicles) do
        pvehicles[string.lower(v.vehicle)] = true
      end

      -- for each existing vehicle in the garage group
      for k,v in pairs(vehicles) do
        if k ~= "_config" and pvehicles[string.lower(k)] == nil then -- not already owned
          submenu[v[1]] = {choose,v[2].." $<br /><br />"..v[3]}
          kitems[v[1]] = k
        end
      end

      vRP.openMenu(player,submenu)
    end
  end,"Buy vehicles."}

  menu["Store vehicle"] = {function(player,choice)
    vRPclient.despawnGarageVehicle(player,{veh_type,75})
  end, "Put your current vehicle in the garage."}
end

local function build_client_garages(source)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    for k,v in pairs(garages) do
      local gtype,x,y,z = table.unpack(v)

      local group = vehicle_groups[gtype]
      if group then
        local gcfg = group._config

        -- enter
        local garage_enter = function(player,area)
          local user_id = vRP.getUserId(source)
          if user_id ~= nil and (gcfg.permission == nil or vRP.hasPermission(user_id,gcfg.permission)) then
            local menu = garage_menus[gtype]
            if menu then
              vRP.openMenu(player,menu)
            end
          end
        end

        -- leave
        local garage_leave = function(player,area)
          vRP.closeMenu(player)
        end

        vRPclient.addBlip(source,{x,y,z,gcfg.blipid,gcfg.blipcolor,"Garage "..gtype})
        vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

        vRP.setArea(source,"vRP:garage"..k,x,y,z,1,1.5,garage_enter,garage_leave)
      end
    end
  end
end

AddEventHandler("vRP:playerSpawned",function()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil and vRP.isFirstSpawn(user_id) then
    build_client_garages(source)
  end
end)
