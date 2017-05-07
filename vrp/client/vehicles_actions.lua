-- vehicles lock/unlock
function tvRP.lockVehicle()
    local distanceParam = 5 -- Change this value to change the distance needed to lock / unlock a vehicle
    local key = 303 -- Change this value to change the key (List of values below)
    local nveh, posnveh = 0, 0
    local player = GetPlayerPed(-1)
    local nveh = SetPlayersLastVehicle(GetVehiclePedIsIn(player, true)) 
    local pReg = tvRP.getRegistrationNumber(player)
    local pLock = GetVehicleNumberPlateText(nveh) -- need to substring
    if nveh ~= 0 then 
        posnveh = GetEntityCoords(nveh, false)
        nvehX, nvehY, nvehZ = posnveh.x, posnveh.y, posnveh.z 

        posPlayer = GetEntityCoords(player, false) 
        playerX, playerY, playerZ = posPlayer.x, posPlayer.y, posPlayer.z 
    end
    if IsControlJustPressed(1, key) then
        if nveh == 0 then
            tvRP.notify("You don't have a vehicle.")
        elseif nveh ~= 0 and pReg == pLock then   
            distanceBetweenVehPlayer = GetDistanceBetweenCoords(nvehX, nvehY, nvehZ, playerX, playerY, playerZ, false)
            if distanceBetweenVehPlayer <= distanceParam then 
                lockStatus = GetVehicleDoorLockStatus(nveh) 
                if lockStatus == 1 or lockStatus == 0 then 
                    engineValue = IsPedInAnyVehicle(player)
                    lockStatus = SetVehicleDoorsLocked(nveh, 2)
                    SetVehicleDoorsLockedForPlayer(nveh, PlayerId(), false)
                    SetVehicleDoorsLockedForAllPlayers(nveh, true)
                    tvRP.notify("Vehicle Locked.")    
                    if not engineValue then
                        SetVehicleEngineOn(nveh, false, false, true)
                    end

                else 
                    lockStatus = SetVehicleDoorsLocked(nveh, 1)
                    SetVehicleDoorsLockedForAllPlayers(nveh, false)
                    tvRP.notify("Vehicle Unlocked.")
                end
            else 
            tvRP.notify("You are too far from the vehicle.")
            end
        else
        tvRP.notify("This is not your vehicle...")
        end  
    end
end

Citizen.CreateThread(function() 
    while true do 
        Wait(0) 
        tvRP.lockVehicle()
    end
end)
