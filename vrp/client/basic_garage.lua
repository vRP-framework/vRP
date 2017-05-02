
local vehicles = {}

function tvRP.spawnGarageVehicle(vtype,name) -- vtype is the vehicle type (one vehicle per type allowed at the same time)
  if vehicles[vtype] == nil then
    -- load vehicle model
    local mhash = GetHashKey(name)

    local i = 0
    while not HasModelLoaded(mhash) and i < 10000 do
      RequestModel(mhash)
      Citizen.Wait(10)
    end

    -- spawn car
    if HasModelLoaded(mhash) then
      local x,y,z = tvRP.getPosition()
      local nveh = CreateVehicle(mhash, x,y,z+1.0, 0.0, true, false)
      SetVehicleOnGroundProperly(nveh)
      SetEntityInvincible(nveh,false)
      SetPedIntoVehicle(GetPlayerPed(-1),nveh,-1) -- put player inside

      vehicles[vtype] = {group,name,nveh} -- set current vehicule

      SetModelAsNoLongerNeeded(mhash)
    end
  else
    tvRP.notify("You can only have one "..vtype.." vehicule out.")
  end
end

function tvRP.despawnGarageVehicle(vtype,max_range)
  local vehicule = vehicles[vtype]
  if vehicule then
    local x,y,z = table.unpack(GetEntityCoords(vehicule[3],true))
    local px,py,pz = tvRP.getPosition()

    if GetDistanceBetweenCoords(x,y,z,px,py,pz,true) < max_range then -- check distance with the vehicule
      -- remove vehicle
      Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicule[3]))
      vehicles[vtype] = nil
    else
      tvRP.notify("Too far away from the vehicle.")
    end
  end
end
