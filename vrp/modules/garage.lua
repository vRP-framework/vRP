local lang = vRP.lang
local Tools = module("vrp","lib/Tools")

-- a basic garage implementation
local Garage = class("Garage", vRP.Extension)

-- SUBCLASS

Garage.User = class("User")

function Garage.User:getVehicles()
  return self.cdata.vehicles
end

-- PRIVATE METHODS

-- menu: garage owned
local function menu_garage_owned(self)
  local function m_get(menu, model)
    local user = menu.user
    vRP.EXT.Garage.remote._spawnVehicle(user.source, model)
    user:closeMenu(menu)
  end

  vRP.EXT.GUI:registerMenuBuilder("garage.owned", function(menu)
    menu.title = lang.garage.owned.title()
    menu.css.header_color = "rgba(255,125,0,0.75)"
    local user = menu.user

    -- vehicles: bought + rent
    local vehicles = {}
    for model in pairs(user:getVehicles()) do
      vehicles[model] = true
    end
    for model in pairs(user.rent_vehicles) do
      vehicles[model] = true
    end

    for model in pairs(vehicles) do
      local veh = menu.data.vehicles[model]
      if veh then
        menu:addOption(veh[1], m_get, veh[3], model)
      end
    end
  end)
end

-- menu: garage buy
local function menu_garage_buy(self)
  local function m_buy(menu, model)
    local user = menu.user
    local uvehicles = user:getVehicles()

    -- buy vehicle
    local veh = menu.data.vehicles[model]
    if veh and user:tryPayment(veh[2]) then
      uvehicles[model] = true

      vRP.EXT.Base.remote._notify(user.source, lang.money.paid({veh[2]}))
      user:closeMenu(menu)
    else
      vRP.EXT.Base.remote._notify(user.source, lang.money.not_enough())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("garage.buy", function(menu)
    menu.title = lang.garage.buy.title()
    menu.css.header_color = "rgba(255,125,0,0.75)"
    local user = menu.user

    local uvehicles = user:getVehicles()

    -- for each existing vehicle in the garage group and not already owned
    for model,veh in pairs(menu.data.vehicles) do
      if model ~= "_config" and not uvehicles[model] then
        menu:addOption(veh[1], m_buy, lang.garage.buy.info({veh[2],veh[3]}), model)
      end
    end
  end)
end

-- menu: garage sell
local function menu_garage_sell(self)
  local function m_sell(menu, model)
    local user = menu.user
    local uvehicles = user:getVehicles()

    local veh = menu.data.vehicles[model]

    local price = math.ceil(veh[2]*self.cfg.sell_factor)

    if uvehicles[model] then -- has vehicle
      user:giveWallet(price)
      uvehicles[model] = nil

      vRP.EXT.Base.remote._notify(user.source,lang.money.received({price}))
      user:closeMenu(menu)
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.not_found())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("garage.sell", function(menu)
    menu.title = lang.garage.sell.title()
    menu.css.header_color = "rgba(255,125,0,0.75)"
    local user = menu.user
    local uvehicles = user:getVehicles()

    -- for each existing vehicle in the garage group and owned
    for model,veh in pairs(menu.data.vehicles) do
      if model ~= "_config" and uvehicles[model] then
        local price = math.ceil(veh[2]*self.cfg.sell_factor)
        menu:addOption(veh[1], m_sell, lang.garage.buy.info({price, veh[3]}), model)
      end
    end
  end)
end

-- menu: garage rent
local function menu_garage_rent(self)
  local function m_rent(menu, model)
    local user = menu.user
    local uvehicles = user:getVehicles()

    -- rent vehicle
    local veh = menu.data.vehicles[model]
    local price = math.ceil(veh[2]*self.cfg.rent_factor)
    if user:tryPayment(price) then
      user.rent_vehicles[model] = true

      vRP.EXT.Base.remote._notify(user.source,lang.money.paid({price}))
      user:closeMenu(menu)
    else
      vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("garage.rent", function(menu)
    menu.title = lang.garage.rent.title()
    menu.css.header_color = "rgba(255,125,0,0.75)"
    local user = menu.user
    local uvehicles = user:getVehicles()

    -- vehicles: bought + rent
    local vehicles = {}
    for model in pairs(user:getVehicles()) do
      vehicles[model] = true
    end
    for model in pairs(user.rent_vehicles) do
      vehicles[model] = true
    end

    -- for each existing vehicle in the garage group and not already owned
    for model,veh in pairs(menu.data.vehicles) do
      if model ~= "_config" and not vehicles[model] then
        local price = math.ceil(veh[2]*self.cfg.rent_factor)
        menu:addOption(veh[1], m_rent, lang.garage.buy.info({price,veh[3]}), model)
      end
    end
  end)
end

-- menu: garage
local function menu_garage(self)
  local function m_owned(menu)
    local smenu = menu.user:openMenu("garage.owned", menu.data)

    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  local function m_buy(menu)
    local smenu = menu.user:openMenu("garage.buy", menu.data)

    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  local function m_sell(menu)
    local smenu = menu.user:openMenu("garage.sell", menu.data)

    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  local function m_rent(menu)
    local smenu = menu.user:openMenu("garage.rent", menu.data)

    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  local function m_store(menu)
    local user = menu.user

    local model = vRP.EXT.Garage.remote.getNearestOwnedVehicle(user.source, 15)
    if model then
      if menu.data.vehicles[model] then -- model in this garage
        vRP.EXT.Garage.remote._despawnVehicle(user.source, model) 
      else
        vRP.EXT.Base.remote._notify(user.source, lang.garage.store.wrong_garage())
      end
    else
      vRP.EXT.Base.remote._notify(user.source, lang.garage.store.too_far())
    end

  end

  vRP.EXT.GUI:registerMenuBuilder("garage", function(menu)
    menu.title = lang.garage.title({menu.data.type})
    menu.css.header_color = "rgba(255,125,0,0.75)"

    menu:addOption(lang.garage.owned.title(), m_owned, lang.garage.owned.description())
    menu:addOption(lang.garage.buy.title(), m_buy, lang.garage.buy.description())
    menu:addOption(lang.garage.sell.title(), m_sell, lang.garage.sell.description())
    menu:addOption(lang.garage.rent.title(), m_rent, lang.garage.rent.description())
    menu:addOption(lang.garage.store.title(), m_store, lang.garage.store.description())
  end)
end

-- menu: vehicle
local function menu_vehicle(self)
end

-- METHODS

function Garage:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/garages")
  self:log(#self.cfg.garages.." garages")

  self.models = {} -- map of models

  -- register models
  for gtype, vehicles in pairs(self.cfg.garage_types) do
    for model in pairs(vehicles) do
      self.models[model] = true
    end
  end

  menu_garage_owned(self)
  menu_garage_buy(self)
  menu_garage_sell(self)
  menu_garage_rent(self)
  menu_garage(self)
  menu_vehicle(self)
end

-- EVENT
Garage.event = {}

function Garage.event:characterLoad(user)
  if not user.cdata.vehicles then
    user.cdata.vehicles = {}
  end

  user.rent_vehicles = {}
end

function Garage.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- register models
    self.remote._registerModels(user.source, self.models)

    -- build garages
    for k,v in pairs(self.cfg.garages) do
      local gtype,x,y,z = table.unpack(v)

      local group = self.cfg.garage_types[gtype]
      if group then
        local gcfg = group._config

        local menu
        local function enter(user)
          if user:hasPermissions(gcfg.permissions or {}) then
            menu = user:openMenu("garage", {type = gtype, vehicles = group})
          end
        end

        -- leave
        local function leave(user)
          if menu then
            user:closeMenu(menu)
          end
        end

        vRP.EXT.Map.remote._addBlip(user.source,x,y,z,gcfg.blipid,gcfg.blipcolor,lang.garage.title({gtype}))
        vRP.EXT.Map.remote._addMarker(user.source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)
        user:setArea("vRP:garage:"..k,x,y,z,1,1.5,enter,leave)
      end
    end
  end
end

--[[
-- VEHICLE MENU

-- define vehicle actions
-- action => {cb(user_id,player,veh_group,veh_name),desc}
local veh_actions = {}

-- open trunk
veh_actions[lang.vehicle.trunk.title()] = {function(user_id,player,name)
  local chestname = "u"..user_id.."veh_"..string.lower(name)
  local max_weight = cfg_inventory.vehicle_chest_weights[string.lower(name)] or cfg_inventory.default_vehicle_chest_weight

  -- open chest
  vRPclient._vc_openDoor(player, name, 5)
  vRP.openChest(player, chestname, max_weight, function()
    vRPclient._vc_closeDoor(player, name, 5)
  end)
end, lang.vehicle.trunk.description()}

-- detach trailer
veh_actions[lang.vehicle.detach_trailer.title()] = {function(user_id,player,name)
  vRPclient._vc_detachTrailer(player, name)
end, lang.vehicle.detach_trailer.description()}

-- detach towtruck
veh_actions[lang.vehicle.detach_towtruck.title()] = {function(user_id,player,name)
  vRPclient._vc_detachTowTruck(player, name)
end, lang.vehicle.detach_towtruck.description()}

-- detach cargobob
veh_actions[lang.vehicle.detach_cargobob.title()] = {function(user_id,player,name)
  vRPclient._vc_detachCargobob(player, name)
end, lang.vehicle.detach_cargobob.description()}

-- lock/unlock
veh_actions[lang.vehicle.lock.title()] = {function(user_id,player,name)
  vRPclient._vc_toggleLock(player, name)
end, lang.vehicle.lock.description()}

-- engine on/off
veh_actions[lang.vehicle.engine.title()] = {function(user_id,player,name)
  vRPclient._vc_toggleEngine(player, name)
end, lang.vehicle.engine.description()}

local function ch_vehicle(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id then
    -- check vehicle
    local ok,name = vRPclient.getNearestOwnedVehicle(player,7)
    if ok then
      -- build vehicle menu
      local menu = vRP.buildMenu("vehicle", {user_id = user_id, player = player, vname = name})
      menu.name=lang.vehicle.title()
      menu.css={top="75px",header_color="rgba(255,125,0,0.75)"}

      for k,v in pairs(veh_actions) do
        menu[k] = {function(player,choice) v[1](user_id,player,name) end, v[2]}
      end

      vRP.openMenu(player,menu)
    else
      vRPclient._notify(player,lang.vehicle.no_owned_near())
    end
  end
end

-- ask trunk (open other user car chest)
local function ch_asktrunk(player,choice)
  local nplayer = vRPclient.getNearestPlayer(player,10)
  local nuser_id = vRP.getUserId(nplayer)
  if nuser_id then
    vRPclient._notify(player,lang.vehicle.asktrunk.asked())
    if vRP.request(nplayer,lang.vehicle.asktrunk.request(),15) then -- request accepted, open trunk
      local ok,name = vRPclient.getNearestOwnedVehicle(nplayer,7)
      if ok then
        local chestname = "u"..nuser_id.."veh_"..string.lower(name)
        local max_weight = cfg_inventory.vehicle_chest_weights[string.lower(name)] or cfg_inventory.default_vehicle_chest_weight

        -- open chest
        local cb_out = function(idname,amount)
          vRPclient._notify(nplayer,lang.inventory.give.given({vRP.getItemName(idname),amount}))
        end

        local cb_in = function(idname,amount)
          vRPclient._notify(nplayer,lang.inventory.give.received({vRP.getItemName(idname),amount}))
        end

        vRPclient._vc_openDoor(nplayer, name, 5)
        vRP.openChest(player, chestname, max_weight, function()
          vRPclient._vc_closeDoor(nplayer, name, 5)
        end,cb_in,cb_out)
      else
        vRPclient._notify(player,lang.vehicle.no_owned_near())
        vRPclient._notify(nplayer,lang.vehicle.no_owned_near())
      end
    else
      vRPclient._notify(player,lang.common.request_refused())
    end
  else
    vRPclient._notify(player,lang.common.no_player_near())
  end
end

-- repair nearest vehicle
local function ch_repair(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id then
    -- anim and repair
    if vRP.tryGetInventoryItem(user_id,"repairkit",1,true) then
      vRPclient._playAnim(player,false,{task="WORLD_HUMAN_WELDING"},false)
      SetTimeout(15000, function()
        vRPclient._fixeNearestVehicle(player,7)
        vRPclient._stopAnim(player,false)
      end)
    end
  end
end

-- replace nearest vehicle
local function ch_replace(player,choice)
  vRPclient._replaceNearestVehicle(player,7)
end

vRP.registerMenuBuilder("main", function(add, data)
  local user_id = vRP.getUserId(data.player)
  if user_id then
    -- add vehicle entry
    local choices = {}
    choices[lang.vehicle.title()] = {ch_vehicle}

    -- add ask trunk
    choices[lang.vehicle.asktrunk.title()] = {ch_asktrunk}

    -- add repair functions
    if vRP.hasPermission(user_id, "vehicle.repair") then
      choices[lang.vehicle.repair.title()] = {ch_repair, lang.vehicle.repair.description()}
    end

    if vRP.hasPermission(user_id, "vehicle.replace") then
      choices[lang.vehicle.replace.title()] = {ch_replace, lang.vehicle.replace.description()}
    end

    add(choices)
  end
end)
--]]

vRP:registerExtension(Garage)
