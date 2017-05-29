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
local cfg_inventory = require("resources/vrp/cfg/inventory")
local vehicle_groups = cfg.garage_types
local lang = vRP.lang

local garages = cfg.garages

-- garage menus

local garage_menus = {}

for group,vehicles in pairs(vehicle_groups) do
  local veh_type = vehicles._config.vtype or "default"

  local menu = {
    name=lang.garage.title({group}),
    css={top = "75px", header_color="rgba(255,125,0,0.75)"}
  }
  garage_menus[group] = menu

  menu[lang.garage.owned.title()] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
      -- build nested menu
      local kitems = {}
      local submenu = {name=lang.garage.title({lang.garage.owned.title()}), css={top="75px",header_color="rgba(255,125,0,0.75)"}}
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
  end,lang.garage.owned.description()}

  menu[lang.garage.buy.title()] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
      -- build nested menu
      local kitems = {}
      local submenu = {name=lang.garage.title({lang.garage.buy.title()}), css={top="75px",header_color="rgba(255,125,0,0.75)"}}
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

            vRPclient.notify(player,{lang.money.paid({vehicle[2]})})
            vRP.closeMenu(player)
          else
            vRPclient.notify(player,{lang.money.not_enough()})
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
          submenu[v[1]] = {choose,lang.garage.buy.info({v[2],v[3]})}
          kitems[v[1]] = k
        end
      end

      vRP.openMenu(player,submenu)
    end
  end,lang.garage.buy.description()}

  menu[lang.garage.store.title()] = {function(player,choice)
    vRPclient.despawnGarageVehicle(player,{veh_type,10}) -- big range cause the car to not despawn
  end, lang.garage.store.description()}
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

        vRPclient.addBlip(source,{x,y,z,gcfg.blipid,gcfg.blipcolor,lang.garage.title({gtype})})
        vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

        vRP.setArea(source,"vRP:garage"..k,x,y,z,1,1.5,garage_enter,garage_leave)
      end
    end
  end
end

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
  if first_spawn then
    build_client_garages(source)
  end
end)

-- VEHICLE MENU

-- define vehicle actions
-- action => {cb(user_id,player,veh_group,veh_name),desc}
local veh_actions = {}

-- open trunk
veh_actions[lang.vehicle.trunk.title()] = {function(user_id,player,vtype,name)
  local chestname = "u"..user_id.."veh_"..string.lower(name)
  local max_weight = cfg_inventory.vehicle_chest_weights[string.lower(name)] or cfg_inventory.default_vehicle_chest_weight

  -- open chest
  vRPclient.vc_openDoor(player, {vtype,5})
  vRP.openChest(player, chestname, max_weight, function()
    vRPclient.vc_closeDoor(player, {vtype,5})
  end)
end, lang.vehicle.trunk.description()}

-- detach trailer
veh_actions[lang.vehicle.detach_trailer.title()] = {function(user_id,player,vtype,name)
  vRPclient.vc_detachTrailer(player, {vtype})
end, lang.vehicle.detach_trailer.description()}


local function ch_vehicle(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    -- check vehicle
    vRPclient.getNearestOwnedVehicle(player,{},function(ok,vtype,name)
      if ok then
        -- build vehicle menu
        local menu = {name=lang.vehicle.title(), css={top="75px",header_color="rgba(255,125,0,0.75)"}}

        for k,v in pairs(veh_actions) do 
          menu[k] = {function(player,choice) v[1](user_id,player,vtype,name) end, v[2]}
        end

        vRP.openMenu(player,menu)
      else
        vRPclient.notify(player,{lang.vehicle.no_owned_near()})
      end
    end)
  end
end

-- ask trunk (open other user car chest)
local function ch_asktrunk(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId(nplayer)
    if nuser_id ~= nil then
      vRPclient.notify(player,{lang.vehicle.asktrunk.asked()})
      vRP.request(nplayer,lang.vehicle.asktrunk.request(),15,function(nplayer,ok)
        if ok then -- request accepted, open trunk
          vRPclient.getNearestOwnedVehicle(player,{},function(ok,vtype,name)
            if ok then
              local chestname = "u"..nuser_id.."veh_"..string.lower(name)
              local max_weight = cfg_inventory.vehicle_chest_weights[string.lower(name)] or cfg_inventory.default_vehicle_chest_weight

              -- open chest
              local cb_out = function(idname,amount)
                vRPclient.notify(nplayer,{lang.inventory.give.given({idname,amount})})
              end

              local cb_in = function(idname,amount)
                vRPclient.notify(nplayer,{lang.inventory.give.received({idname,amount})})
              end

              vRPclient.vc_openDoor(nplayer, {vtype,5})
              vRP.openChest(player, chestname, max_weight, function()
                vRPclient.vc_closeDoor(nplayer, {vtype,5})
              end,cb_in,cb_out)
            else
              vRPclient.notify(player,{lang.vehicle.no_owned_near()})
              vRPclient.notify(nplayer,{lang.vehicle.no_owned_near()})
            end
          end)
        else
          vRPclient.notify(player,{lang.common.request_refused()})
        end
      end)
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end

AddEventHandler("vRP:buildMainMenu",function(player)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    -- add vehicle entry
    local choices = {}
    choices[lang.vehicle.title()] = {ch_vehicle}

    -- add ask trunk
    choices[lang.vehicle.asktrunk.title()] = {ch_asktrunk}

    vRP.buildMainMenu(player,choices)
  end
end)
