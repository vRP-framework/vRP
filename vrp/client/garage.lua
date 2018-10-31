
local Garage = class("Garage", vRP.Extension)

-- METHODS

function Garage:__construct()
  vRP.Extension.__construct(self)

  -- init decorators
  DecorRegister("vRP.owner", 3)

  self.vehicles = {} -- map of vehicle model => veh id (owned vehicles)
  self.hash_models = {} -- map of hash => model
end

-- veh: vehicle game id
-- return owner character id and model or nil if not managed by vRP
function Garage:getVehicleInfo(veh)
  if veh and DecorExistOn(veh, "vRP.owner") then
    local model = self.hash_models[GetEntityModel(veh)]
    if model then
      return DecorGetInt(veh, "vRP.owner"), model
    end
  end
end

-- return true if spawned (if not already out)
function Garage:spawnVehicle(model, pos) -- one vehicle per model allowed at the same time
  local vehicle = self.vehicles[model]
  if not vehicle then
    -- load vehicle model
    local mhash = GetHashKey(model)

    local i = 0
    while not HasModelLoaded(mhash) and i < 10000 do
      RequestModel(mhash)
      Citizen.Wait(10)
      i = i+1
    end

    -- spawn car
    if HasModelLoaded(mhash) then
      local x,y,z
      if pos then
        x,y,z = table.unpack(pos)
      else
        x,y,z = vRP.EXT.Base:getPosition()
      end

      local nveh = CreateVehicle(mhash, x,y,z+0.5, 0.0, true, false)
      SetVehicleOnGroundProperly(nveh)
      SetEntityInvincible(nveh,false)
      SetPedIntoVehicle(GetPlayerPed(-1),nveh,-1) -- put player inside
      SetVehicleNumberPlateText(nveh, "P "..vRP.EXT.Identity:getRegistrationNumber())
      SetEntityAsMissionEntity(nveh, true, true)
      SetVehicleHasBeenOwnedByPlayer(nveh,true)

      -- set decorators
      DecorSetInt(veh, "vRP.owner", vRP.EXT.Base.id)
      self.vehicles[model] = nveh -- mark as owned

      SetModelAsNoLongerNeeded(mhash)

      vRP:triggerEvent("garageVehicleSpawn", model)
    end

    return true
  end
end

-- return true if despawned
function Garage:despawnVehicle(model)
  local veh = self.vehicles[model]
  if veh then
    vRP:triggerEvent("garageVehicleStore", model)

    -- remove vehicle
    SetVehicleHasBeenOwnedByPlayer(veh,false)
    SetEntityAsMissionEntity(veh, false, true)
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
    self.vehicles[model] = nil

    return true
  end
end

-- check vehicles validity
--[[
Citizen.CreateThread(function()
  Citizen.Wait(30000)

  for k,v in pairs(vehicles) do
    if IsEntityAVehicle(v[3]) then -- valid, save position
      v.pos = {table.unpack(GetEntityCoords(vehicle[3],true))}
    elseif v.pos then -- not valid, respawn if with a valid position
      print("[vRP] invalid vehicle "..v[1]..", respawning...")
      tvRP.spawnGarageVehicle(v[1], v[2], v.pos)
    end
  end
end)
--]]



-- return map of veh => distance
function Garage:getNearestVehicles(radius)
  local r = {}

  local px,py,pz = vRP.EXT.Base:getPosition()

  local vehs = {}
  local it, veh = FindFirstVehicle()
  if veh then table.insert(vehs, veh) end
  local ok
  repeat
    ok, veh = FindNextVehicle(it)
    if ok and veh then table.insert(vehs, veh) end
  until not ok
  EndFindVehicle(it)

  for _,veh in pairs(vehs) do
    local x,y,z = table.unpack(GetEntityCoords(veh,true))
    local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
    if distance <= radius then
      r[veh] = distance
    end
  end

  return r
end

function Garage:getNearestVehicle(radius)
  local veh

  local vehs = self:getNearestVehicles(radius)
  local min = radius+10.0
  for _veh,dist in pairs(vehs) do
    if dist < min then
      min = dist 
      veh = _veh 
    end
  end

  return veh 
end

-- try to re-own the nearest vehicle
function Garage:tryOwnNearestVehicle(radius)
  local veh = self:getNearestVehicle(radius)
  if veh then
    local cid, model = self:getVehicleInfo(veh)
    if cid and vRP.EXT.Base.cid == cid then
      self.vehicles[model] = veh
    end
  end
end

function Garage:fixNearestVehicle(radius)
  local veh = self:getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleFixed(veh)
  end
end

function Garage:replaceNearestVehicle(radius)
  local veh = self:getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleOnGroundProperly(veh)
  end
end

-- return model or nil
function Garage:getNearestOwnedVehicle(radius)
  self:tryOwnNearestVehicle(radius) -- get back network lost vehicles

  local px,py,pz = vRP.EXT.Base:getPosition()
  local min_dist
  local min_k
  for k,veh in pairs(self.vehicles) do
    local x,y,z = table.unpack(GetEntityCoords(veh,true))
    local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)

    if dist <= radius+0.0001 then
      if not min_dist or dist < min_dist then
        min_dist = dist
        min_k = k
      end
    end
  end

  return min_k
end

-- return ok,x,y,z
function Garage:getAnyOwnedVehiclePosition()
  for model,veh in pairs(self.vehicles) do
    if IsEntityAVehicle(veh) then
      local x,y,z = table.unpack(GetEntityCoords(v[2],true))
      return true,x,y,z
    end
  end

  return false,0,0,0
end

-- return x,y,z or nil
function Garage:getOwnedVehiclePosition(model)
  local veh = self.vehicles[model]
  if veh then
    return table.unpack(GetEntityCoords(veh,true))
  end
end

-- eject the ped from the vehicle
function Garage:ejectVehicle()
  local ped = GetPlayerPed(-1)
  if IsPedSittingInAnyVehicle(ped) then
    local veh = GetVehiclePedIsIn(ped,false)
    TaskLeaveVehicle(ped, veh, 4160)
  end
end

function Garage:isInVehicle()
  local ped = GetPlayerPed(-1)
  return IsPedSittingInAnyVehicle(ped) 
end

-- return model or nil if not in owned vehicle
function Garage:getInOwnedVehicleModel()
  local veh = GetVehiclePedIsIn(ped,false)
  local cid, model = self:getVehicleInfo(veh)
  if cid and cid == vRP.EXT.Base.cid then
    return model
  end
end

-- VEHICLE COMMANDS

function Garage:vc_openDoor(model, door_index)
  local vehicle = self.vehicles[model]
  if vehicle then
    SetVehicleDoorOpen(vehicle,door_index,0,false)
  end
end

function Garage:vc_closeDoor(model, door_index)
  local vehicle = self.vehicles[model]
  if vehicle then
    SetVehicleDoorShut(vehicle,door_index)
  end
end

function Garage:vc_detachTrailer(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    DetachVehicleFromTrailer(vehicle)
  end
end

function Garage:vc_detachTowTruck(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    local ent = GetEntityAttachedToTowTruck(vehicle)
    if IsEntityAVehicle(ent) then
      DetachVehicleFromTowTruck(vehicle,ent)
    end
  end
end

function Garage:vc_detachCargobob(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    local ent = GetVehicleAttachedToCargobob(vehicle)
    if IsEntityAVehicle(ent) then
      DetachVehicleFromCargobob(vehicle,ent)
    end
  end
end

function Garage:vc_toggleEngine(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    local running = Citizen.InvokeNative(0xAE31E7DF9B5B132E,vehicle) -- GetIsVehicleEngineRunning
    SetVehicleEngineOn(vehicle,not running,true,true)
    if running then
      SetVehicleUndriveable(vehicle,true)
    else
      SetVehicleUndriveable(vehicle,false)
    end
  end
end

-- return true if locked, false if unlocked
function Garage:vc_toggleLock(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    local veh = vehicle
    local locked = GetVehicleDoorLockStatus(veh) >= 2
    if locked then -- unlock
      SetVehicleDoorsLockedForAllPlayers(veh, false)
      SetVehicleDoorsLocked(veh,1)
      SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
      return false
    else -- lock
      SetVehicleDoorsLocked(veh,2)
      SetVehicleDoorsLockedForAllPlayers(veh, true)
      return true
    end
  end
end

-- TUNNEL
Garage.tunnel = {}

function Garage.tunnel:registerModels(models)
  -- generate models hashes
  for model in pairs(models) do
    local hash = GetHashKey(model)
    if hash then
      self.hash_models[hash] = model
    end
  end
end

Garage.tunnel.spawnVehicle = Garage.spawnVehicle
Garage.tunnel.despawnVehicle = Garage.despawnVehicle
Garage.tunnel.fixNearestVehicle = Garage.fixNearestVehicle
Garage.tunnel.replaceNearestVehicle = Garage.replaceNearestVehicle
Garage.tunnel.getNearestOwnedVehicle = Garage.getNearestOwnedVehicle
Garage.tunnel.getAnyOwnedVehiclePosition = Garage.getAnyOwnedVehiclePosition
Garage.tunnel.getOwnedVehiclePosition = Garage.getOwnedVehiclePosition
Garage.tunnel.getInOwnedVehicleModel = Garage.getInOwnedVehicleModel
Garage.tunnel.ejectVehicle = Garage.ejectVehicle
Garage.tunnel.isInVehicle = Garage.isInVehicle
Garage.tunnel.vc_openDoor = Garage.vc_openDoor
Garage.tunnel.vc_closeDoor = Garage.vc_closeDoor
Garage.tunnel.vc_detachTrailer = Garage.vc_detachTrailer
Garage.tunnel.vc_detachTowTruck = Garage.vc_detachTowTruck
Garage.tunnel.vc_detachCargobob = Garage.vc_detachCargobob
Garage.tunnel.vc_toggleEngine = Garage.vc_toggleEngine
Garage.tunnel.vc_toggleLock = Garage.vc_toggleLock

vRP:registerExtension(Garage)
