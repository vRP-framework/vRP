-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.survival then return end

local Luang = module("vrp", "lib/Luang")

local Survival = class("Survival", vRP.Extension)

function Survival:__construct()
  vRP.Extension.__construct(self)

  self.in_coma = false -- flag
  self.coma_left = vRP.cfg.coma_max_duration*60 -- seconds

  self.luang = Luang()
  self.lang = self.luang.lang

  -- task: impact water and food when the player is running, etc (every 5 seconds)
  Citizen.CreateThread(function()
    local it = 0

    -- consumption for one minute
    local twater = 0
    local tfood = 0

    while true do
      Citizen.Wait(5000)

      if IsPlayerPlaying(PlayerId()) then
        local ped = GetPlayerPed(-1)

        local water = 0
        local food = 0

        -- on foot, increase water/food in function of velocity
        if IsPedOnFoot(ped) and not vRP.EXT.Admin.noclip then
          local factor = math.min(vRP.EXT.Base:getSpeed(),10)

          water = water+0.01*factor
          food = food+0.005*factor
        end

        -- in melee combat, increase
        if IsPedInMeleeCombat(ped) then
          water = water+0.1
          food = food+0.05
        end

        -- injured, hurt, increase
        if IsPedHurt(ped) or IsPedInjured(ped) then
          water = water+0.02
          food = food+0.01
        end

        twater = twater+water/12
        tfood = tfood+food/12

        it = it+1
        if it >= 12 then
          it = 0
          self.remote._consume(twater, tfood)
          twater = 0
          tfood = 0
        end
      end
    end
  end)

  -- task: coma
  Citizen.CreateThread(function() 
    local PlayerState = vRP.EXT.PlayerState

    while true do
      Citizen.Wait(0)
      local ped = GetPlayerPed(-1)
      
      local health = GetEntityHealth(ped)
      if health <= vRP.cfg.coma_threshold and self.coma_left > 0 then
        if not self.in_coma then -- go to coma state
          if IsEntityDead(ped) then -- if dead, resurrect
            local x,y,z = vRP.EXT.Base:getPosition()
            NetworkResurrectLocalPlayer(x, y, z, true, true, false)
            Citizen.Wait(0)
          end

          -- coma state
          self.in_coma = true

          SetEntityHealth(ped, vRP.cfg.coma_threshold)
          SetEntityInvincible(ped,true)
          vRP.EXT.Base:playScreenEffect(vRP.cfg.coma_effect,-1)
          if vRP.EXT.Garage then
            vRP.EXT.Garage:ejectVehicle()
          end
          vRP.EXT.Base:setRagdoll(true)

          vRP:triggerEvent("playerComaState", self.in_coma)
        else -- in coma
          -- maintain life
          if health < vRP.cfg.coma_threshold then 
            SetEntityHealth(ped, vRP.cfg.coma_threshold) 
          end
        end
      else
        if self.in_coma and PlayerState.state_ready then -- get out of coma state
          self.in_coma = false
          SetEntityInvincible(ped,false)
          vRP.EXT.Base:setRagdoll(false)
          vRP.EXT.Base:stopScreenEffect(vRP.cfg.coma_effect)

          if self.coma_left <= 0 then -- get out of coma by death
            SetEntityHealth(ped, 0)
          end

          SetTimeout(5000, function()  -- able to be in coma again after coma death after 5 seconds
            self.coma_left = vRP.cfg.coma_max_duration*60
          end)

          vRP:triggerEvent("playerComaState", self.in_coma)
        end
      end
    end
  end)

 -- task: coma decrease
  Citizen.CreateThread(function()
    while true do 
      Citizen.Wait(1000)
      if self.in_coma then
        self.coma_left = self.coma_left-1
      end
    end
  end)

  -- task: disable health regen, conflicts with coma system
  Citizen.CreateThread(function() 
    while true do
      Citizen.Wait(100)

      -- prevent health regen
      SetPlayerHealthRechargeMultiplier(PlayerId(), 0)
    end
  end)

  -- task: controls
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      -- coma controls
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.survival.leave_coma))
        and self.coma_left <= (vRP.cfg.coma_max_duration-vRP.cfg.coma_min_duration)*60 then -- min check
        self:killComa()
      end
    end
  end)
end

function Survival:varyHealth(variation)
  local ped = GetPlayerPed(-1)

  local n = math.floor(GetEntityHealth(ped)+variation)
  SetEntityHealth(ped,n)
end

function Survival:setFriendlyFire(flag)
  NetworkSetFriendlyFireOption(flag)
  SetCanAttackFriendly(GetPlayerPed(-1), flag, flag)
end

function Survival:setPolice(flag)
  local player = PlayerId()
  SetPoliceIgnorePlayer(player, not flag)
  SetDispatchCopsForPlayer(player, flag)
end

-- COMA SYSTEM

function Survival:isInComa()
  return self.in_coma
end

-- kill the player if in coma
function Survival:killComa()
  if self.in_coma then
    self.coma_left = 0
  end
end

-- EVENT
Survival.event = {}

local coma_css = [[
.div_coma_display{
  position: absolute;
  left: 0;
  top: 50%;
  width: 100%;
  margin: auto;
  background-color: rgba(0,0,0,0.75);
  color: white;
  font-weight: bold;
  font-size: 1.2em;
  padding-top: 20px;
  padding-bottom: 20px;
  text-align: center;
}

.countdown, .key{
  color: red;
}
]]

function Survival.event:playerComaState(coma)
  -- display

  if coma then
    vRP.EXT.GUI:setDiv("coma_display", coma_css, self.lang.coma_display({vRP.cfg.coma_min_duration*60, self.coma_left}))
  else
    vRP.EXT.GUI:removeDiv("coma_display")
  end
end

-- TUNNEL
Survival.tunnel = {}

function Survival.tunnel:setConfig(coma_display)
  self.luang:load({coma_display = coma_display})
end

Survival.tunnel.isInComa = Survival.isInComa
Survival.tunnel.killComa = Survival.killComa
Survival.tunnel.setFriendlyFire = Survival.setFriendlyFire
Survival.tunnel.setPolice = Survival.setPolice
Survival.tunnel.varyHealth = Survival.varyHealth

vRP:registerExtension(Survival)
