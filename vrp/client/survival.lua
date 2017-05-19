-- api

function tvRP.varyHealth(variation)
  local ped = GetPlayerPed(-1)

  local n = math.floor(GetEntityHealth(ped)+variation)
  SetEntityHealth(ped,n)
end

function tvRP.getHealth()
  return GetEntityHealth(GetPlayerPed(-1))
end

function tvRP.setHealth(health)
  local n = math.floor(health)
  SetEntityHealth(GetPlayerPed(-1),n)
end

function tvRP.setFriendlyFire(flag)
  NetworkSetFriendlyFireOption(flag)
  SetCanAttackFriendly(GetPlayerPed(-1), flag, flag)
end

function tvRP.setPolice(flag)
  local player = PlayerId()
  SetPoliceIgnorePlayer(player, not flag)
  SetDispatchCopsForPlayer(player, flag)
end

-- impact thirst and hunger when the player is running (every 5 seconds)
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5000)

    if IsPlayerPlaying(PlayerId()) then
      local ped = GetPlayerPed(-1)

      -- variations for one minute
      local vthirst = 0
      local vhunger = 0

      -- on foot, increase thirst/hunger in function of velocity
      if IsPedOnFoot(ped) then
        local factor = math.min(tvRP.getSpeed(),10)

        vthirst = vthirst+1*factor
        vhunger = vhunger+0.5*factor
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
  end
end)

-- coma system
local in_coma = false
local coma_health = cfg.coma_threshold
local coma_decrease_delay = math.floor(cfg.coma_duration*60000/(cfg.coma_threshold-100))

Citizen.CreateThread(function() -- coma thread
  while true do
    local ped = GetPlayerPed(-1)
    Citizen.Wait(0)
    
    if GetEntityHealth(ped) <= cfg.coma_threshold then
      if not in_coma then -- go to coma state
        in_coma = true
        tvRP.setRagdoll(true)
        coma_health = cfg.coma_threshold -- init coma health
      end

      -- stabilize health
      SetEntityHealth(ped, coma_health)
    else
      if in_coma then
        in_coma = false
        tvRP.setRagdoll(false)
      end
    end
  end
end)

Citizen.CreateThread(function() -- coma decrease thread
  while true do 
    Citizen.Wait(coma_decrease_delay)
    coma_health = coma_health-1
  end
end)

function tvRP.isInComa()
  return in_coma
end
