-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)


if not vRP.modules.police then return end

-- this module define some police tools and functions
local Police = class("Police", vRP.Extension)

function Police:__construct()
  vRP.Extension.__construct(self)

  self.handcuffed = false
  self.cop = false
  self.wanted_level = 0

  -- task: keep handcuffed animation
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(15000)
      if self.handcuffed then
        vRP.EXT.Base:playAnim(true,{{"mp_arresting","idle",1}},true)
      end
    end
  end)

  -- task: force stealth movement while handcuffed (prevent use of fist and slow the player)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      if self.handcuffed then
        SetPedStealthMovement(GetPlayerPed(-1),true,"")
        DisableControlAction(0,21,true) -- disable sprint
        DisableControlAction(0,24,true) -- disable attack
        DisableControlAction(0,25,true) -- disable aim
        DisableControlAction(0,47,true) -- disable weapon
        DisableControlAction(0,58,true) -- disable weapon
        DisableControlAction(0,263,true) -- disable melee
        DisableControlAction(0,264,true) -- disable melee
        DisableControlAction(0,257,true) -- disable melee
        DisableControlAction(0,140,true) -- disable melee
        DisableControlAction(0,141,true) -- disable melee
        DisableControlAction(0,142,true) -- disable melee
        DisableControlAction(0,143,true) -- disable melee
        DisableControlAction(0,75,true) -- disable exit vehicle
        DisableControlAction(27,75,true) -- disable exit vehicle
        DisableControlAction(0,22,true) -- disable jump
        DisableControlAction(0,32,true) -- disable move up
        DisableControlAction(0,268,true)
        DisableControlAction(0,33,true) -- disable move down
        DisableControlAction(0,269,true)
        DisableControlAction(0,34,true) -- disable move left
        DisableControlAction(0,270,true)
        DisableControlAction(0,35,true) -- disable move right
        DisableControlAction(0,271,true)
      end
    end
  end)

  -- task: follow 
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5000)
      if self.follow_player then
        local tplayer = GetPlayerFromServerId(self.follow_player)
        local ped = GetPlayerPed(-1)
        if NetworkIsPlayerConnected(tplayer) then
          local tped = GetPlayerPed(tplayer)
          TaskGoToEntity(ped, tped, -1, 1.0, 10.0, 1073741824.0, 0)
          SetPedKeepTask(ped, true)
        end
      end
    end
  end)

  -- task: jail
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5)
      if self.current_jail then
        local x,y,z = vRP.EXT.Base:getPosition()

        local dx = x-self.current_jail[1]
        local dy = y-self.current_jail[2]
        local dist = math.sqrt(dx*dx+dy*dy)

        if dist >= self.current_jail[4] then
          local ped = GetPlayerPed(-1)
          SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001) -- stop player

          -- normalize + push to the edge + add origin
          dx = dx/dist*self.current_jail[4]+self.current_jail[1]
          dy = dy/dist*self.current_jail[4]+self.current_jail[2]

          -- teleport player at the edge
          SetEntityCoordsNoOffset(ped,dx,dy,z,true,true,true)
        end
      end
    end
  end)

  -- task: update wanted level
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5000)

      -- if cop, reset wanted level
      if self.cop then
        ClearPlayerWantedLevel(PlayerId())
        SetPlayerWantedLevelNow(PlayerId(),false)
      end
      
      -- update level
      local nwanted_level = GetPlayerWantedLevel(PlayerId())
      if nwanted_level ~= self.wanted_level then
        self.wanted_level = nwanted_level
        self.remote._updateWantedLevel(self.wanted_level)
      end
    end
  end)

  -- task: detect vehicle stealing
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(1)
      local ped = GetPlayerPed(-1)
      if IsPedTryingToEnterALockedVehicle(ped) or IsPedJacking(ped) then
        Citizen.Wait(2000) -- wait x seconds before setting wanted
        local model = vRP.EXT.Garage:getNearestOwnedVehicle(5)
        if not model then -- prevent stealing detection on owned vehicle
          for i=0,4 do -- keep wanted for 1 minutes 30 seconds
            self:applyWantedLevel(2)
            Citizen.Wait(15000)
          end
        end
        Citizen.Wait(15000) -- wait 15 seconds before checking again
      end
    end
  end)
end

-- set player as cop (true or false)
function Police:setCop(flag)
  self.cop = flag
  SetPedAsCop(GetPlayerPed(-1),flag)
end

-- HANDCUFF

function Police:toggleHandcuff()
  self.handcuffed = not self.handcuffed

  SetEnableHandcuffs(GetPlayerPed(-1), self.handcuffed)
  if self.handcuffed then
    vRP.EXT.Base:playAnim(true,{{"mp_arresting","idle",1}},true)
  else
    vRP.EXT.Base:stopAnim(true)
    SetPedStealthMovement(GetPlayerPed(-1),false,"") 
  end
end

function Police:setHandcuffed(flag)
  if self.handcuffed ~= flag then
    self:toggleHandcuff()
  end
end

function Police:isHandcuffed()
  return self.handcuffed
end

function Police:putInNearestVehicleAsPassenger(radius)
  local veh = vRP.EXT.Garage:getNearestVehicle(radius)

  if IsEntityAVehicle(veh) then
    for i=1,math.max(GetVehicleMaxNumberOfPassengers(veh),3) do
      if IsVehicleSeatFree(veh,i) then
        SetPedIntoVehicle(GetPlayerPed(-1),veh,i)
        return true
      end
    end
  end
  
  return false
end

-- FOLLOW

-- follow another player
-- player: nil to disable
function Police:followPlayer(player)
  self.follow_player = player

  if not player then -- unfollow
    ClearPedTasks(GetPlayerPed(-1))
  end
end

-- return player or nil if not following anyone
function Police:getFollowedPlayer()
  return self.follow_player
end

-- JAIL

-- jail the player in a no-top no-bottom cylinder 
function Police:jail(x,y,z,radius)
  vRP.EXT.Base:teleport(x,y,z) -- teleport to center
  self.current_jail = {x+0.0001,y+0.0001,z+0.0001,radius+0.0001}
end

-- unjail the player
function Police:unjail()
  self.current_jail = nil
end

function Police:isJailed()
  return self.current_jail ~= nil
end

-- WANTED

function Police:applyWantedLevel(new_wanted)
  Citizen.CreateThread(function()
    local old_wanted = GetPlayerWantedLevel(PlayerId())
    local wanted = math.max(old_wanted,new_wanted)
    ClearPlayerWantedLevel(PlayerId())
    SetPlayerWantedLevelNow(PlayerId(),false)
    Citizen.Wait(10)
    SetPlayerWantedLevel(PlayerId(),wanted,false)
    SetPlayerWantedLevelNow(PlayerId(),false)
  end)
end

-- TUNNEL
Police.tunnel = {}

Police.tunnel.setCop = Police.setCop
Police.tunnel.toggleHandcuff = Police.toggleHandcuff
Police.tunnel.setHandcuffed = Police.setHandcuffed
Police.tunnel.isHandcuffed = Police.isHandcuffed
Police.tunnel.putInNearestVehicleAsPassenger = Police.putInNearestVehicleAsPassenger
Police.tunnel.followPlayer = Police.followPlayer
Police.tunnel.getFollowedPlayer = Police.getFollowedPlayer
Police.tunnel.jail = Police.jail
Police.tunnel.unjail = Police.unjail
Police.tunnel.isJailed = Police.isJailed
Police.tunnel.applyWantedLevel = Police.applyWantedLevel

vRP:registerExtension(Police)
