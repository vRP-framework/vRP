function tvRP.varyHealth(variation)
  local ped = GetPlayerPed(-1)

  SetEntityHealth(ped,GetEntityHealth(ped)+variation)
end

-- impact thirst and hunger when the player is running (every 5 seconds)
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5000)

    local ped = GetPlayerPed(-1)

    -- variations for one minute
    local vthirst = 0
    local vhunger = 0

    -- not in vehicle, slight increase thirst/hunger (inconfort)
    if not IsPedSittingInAnyVehicle(ped) then
      vthirst = vthirst+1
      vhunger = vhunger+0.5
    end

    -- in melee combat, increase
    if IsPedInMeleeCombat(ped) then
      vthirst = vthirst+10
      vhunger = vhunger+5
    end

    -- injured, hurt, increase
    if IsPedHurt(ped) or IsPedInjured(ped) then
      vthirst = vthirst+2
      vhunger = vhunger+1
    end

    -- do variation
    if vthirst ~= 0 then
      vRPserver.varyThirst({vthirst/12.0})
    end

    if vhunger ~= 0 then
      vRPserver.varyHunger({vhunger/12.0})
    end
  end
end)
