-- init vRP client context

local Luaoop = module("vrp", "lib/Luaoop")
class = Luaoop.class
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP() -- instantiate vRP

local pvRP = {}
-- load script in vRP context
function pvRP.loadScript(resource, path)
  module(resource, path)
end

Proxy.addInterface("vRP", pvRP)

-- events

AddEventHandler("playerSpawned",function()
  TriggerServerEvent("vRPcli:playerSpawned")
end)

AddEventHandler("onPlayerDied",function(player,reason)
  TriggerServerEvent("vRPcli:playerDied")
end)

AddEventHandler("onPlayerKilled",function(player,killer,reason)
  TriggerServerEvent("vRPcli:playerDied")
end)

-- Base extension

local Tools = module("vrp", "lib/Tools")

local Base = class("Base", vRP.Extension)
Base.tunnel = {}

function Base:__construct()
  vRP.Extension.__construct(self)

  self.players = {} -- keep track of connected players (server id)

  -- voice proximity task
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(500)
      if vRP.cfg.vrp_voip then -- vRP voip
        NetworkSetTalkerProximity(0) -- disable voice chat
      else -- regular voice chat
        local ped = GetPlayerPed(-1)
        local proximity = vRP.cfg.voice_proximity

        if IsPedSittingInAnyVehicle(ped) then
          local veh = GetVehiclePedIsIn(ped,false)
          local hash = GetEntityModel(veh)
          -- make open vehicles (bike,etc) use the default proximity
          if IsThisModelACar(hash) or IsThisModelAHeli(hash) or IsThisModelAPlane(hash) then
            proximity = vRP.cfg.voice_proximity_vehicle
          end
        elseif self:isInside() then
          proximity = vRP.cfg.voice_proximity_inside
        end

        NetworkSetTalkerProximity(proximity+0.0001)
      end
    end
  end)

  self.ragdoll = false
  -- ragdoll thread
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(10)
      if self.ragdoll then
        SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
      end
    end
  end)

  self.anims = {}
  self.anim_ids = Tools.newIDGenerator()
end

function Base:teleport(x,y,z)
  self:unjail() -- force unjail before a teleportation
  SetEntityCoords(GetPlayerPed(-1), x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  vRP.EXT.PlayerState:updatePos(x,y,z)
end

-- return x,y,z
function Base:getPosition()
  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
  return x,y,z
end

-- return false if in exterior, true if inside a building
function Base:isInside()
  local x,y,z = self:getPosition()
  return not (GetInteriorAtCoords(x,y,z) == 0)
end

-- return vx,vy,vz
function Base:getSpeed()
  local vx,vy,vz = table.unpack(GetEntityVelocity(GetPlayerPed(-1)))
  return math.sqrt(vx*vx+vy*vy+vz*vz)
end

function Base:getCamDirection()
  local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
  local pitch = GetGameplayCamRelativePitch()

  local x = -math.sin(heading*math.pi/180.0)
  local y = math.cos(heading*math.pi/180.0)
  local z = math.sin(pitch*math.pi/180.0)

  -- normalize
  local len = math.sqrt(x*x+y*y+z*z)
  if len ~= 0 then
    x = x/len
    y = y/len
    z = z/len
  end

  return x,y,z
end

function Base:getNearestPlayers(radius)
  local r = {}

  local ped = GetPlayerPed(i)
  local pid = PlayerId()
  local px,py,pz = self:getPosition()

  --[[
  for i=0,GetNumberOfPlayers()-1 do
    if i ~= pid then
      local oped = GetPlayerPed(i)

      local x,y,z = table.unpack(GetEntityCoords(oped,true))
      local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
      if distance <= radius then
        r[GetPlayerServerId(i)] = distance
      end
    end
  end
  --]]

  for k,v in pairs(self.players) do
    local player = GetPlayerFromServerId(k)

    if v and player ~= pid and NetworkIsPlayerConnected(player) then
      local oped = GetPlayerPed(player)
      local x,y,z = table.unpack(GetEntityCoords(oped,true))
      local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
      if distance <= radius then
        r[GetPlayerServerId(player)] = distance
      end
    end
  end

  return r
end

function Base:getNearestPlayer(radius)
  local p = nil

  local players = self:getNearestPlayers(radius)
  local min = radius+10.0
  for k,v in pairs(players) do
    if v < min then
      min = v
      p = k
    end
  end

  return p
end

function Base:notify(msg)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(msg)
  DrawNotification(true, false)
end

function Base:notifyPicture(icon, type, sender, title, text)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  SetNotificationMessage(icon, icon, true, type, sender, title, text)
  DrawNotification(false, true)
end

-- SCREEN

-- play a screen effect
-- name, see https://wiki.fivem.net/wiki/Screen_Effects
-- duration: in seconds, if -1, will play until stopScreenEffect is called
function Base:playScreenEffect(name, duration)
  if duration < 0 then -- loop
    StartScreenEffect(name, 0, true)
  else
    StartScreenEffect(name, 0, true)

    Citizen.CreateThread(function() -- force stop the screen effect after duration+1 seconds
      Citizen.Wait(math.floor((duration+1)*1000))
      StopScreenEffect(name)
    end)
  end
end

-- stop a screen effect
-- name, see https://wiki.fivem.net/wiki/Screen_Effects
function Base:stopScreenEffect(name)
  StopScreenEffect(name)
end

-- ANIM

-- animations dict and names: http://docs.ragepluginhook.net/html/62951c37-a440-478c-b389-c471230ddfc5.htm

-- play animation (new version)
-- upper: true, only upper body, false, full animation
-- seq: list of animations as {dict,anim_name,loops} (loops is the number of loops, default 1) or a task def (properties: task, play_exit)
-- looping: if true, will infinitely loop the first element of the sequence until stopAnim is called
function Base:playAnim(upper, seq, looping)
  if seq.task then -- is a task (cf https://github.com/ImagicTheCat/vRP/pull/118)
    self:stopAnim(true)

    local ped = GetPlayerPed(-1)
    if seq.task == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then -- special case, sit in a chair
      local x,y,z = self:getPosition()
      TaskStartScenarioAtPosition(ped, seq.task, x, y, z-1, GetEntityHeading(ped), 0, 0, false)
    else
      TaskStartScenarioInPlace(ped, seq.task, 0, not seq.play_exit)
    end
  else -- a regular animation sequence
    self:stopAnim(self, upper)

    local flags = 0
    if upper then flags = flags+48 end
    if looping then flags = flags+1 end

    Citizen.CreateThread(function()
      -- prepare unique id to stop sequence when needed
      local id = self.anim_ids:gen()
      self.anims[id] = true

      for k,v in pairs(seq) do
        local dict = v[1]
        local name = v[2]
        local loops = v[3] or 1

        for i=1,loops do
          if self.anims[id] then -- check animation working
            local first = (k == 1 and i == 1)
            local last = (k == #seq and i == loops)

            -- request anim dict
            RequestAnimDict(dict)
            local i = 0
            while not HasAnimDictLoaded(dict) and i < 1000 do -- max time, 10 seconds
              Citizen.Wait(10)
              RequestAnimDict(dict)
              i = i+1
            end

            -- play anim
            if HasAnimDictLoaded(dict) and self.anims[id] then
              local inspeed = 8.0001
              local outspeed = -8.0001
              if not first then inspeed = 2.0001 end
              if not last then outspeed = 2.0001 end

              TaskPlayAnim(GetPlayerPed(-1),dict,name,inspeed,outspeed,-1,flags,0,0,0,0)
            end

            Citizen.Wait(0)
            while GetEntityAnimCurrentTime(GetPlayerPed(-1),dict,name) <= 0.95 and IsEntityPlayingAnim(GetPlayerPed(-1),dict,name,3) and self.anims[id] do
              Citizen.Wait(0)
            end
          end
        end
      end

      -- free id
      self.anim_ids:free(id)
      self.anims[id] = nil
    end)
  end
end

-- stop animation (new version)
-- upper: true, stop the upper animation, false, stop full animations
function Base:stopAnim(upper)
  self.anims = {} -- stop all sequences
  if upper then
    ClearPedSecondaryTask(GetPlayerPed(-1))
  else
    ClearPedTasks(GetPlayerPed(-1))
  end
end

-- RAGDOLL

-- set player ragdoll flag (true or false)
function Base:setRagdoll(flag)
  self.ragdoll = flag
end

-- SOUND
-- some lists: 
-- pastebin.com/A8Ny8AHZ
-- https://wiki.gtanet.work/index.php?title=FrontEndSoundlist

-- play sound at a specific position
function Base:playSpatializedSound(dict,name,x,y,z,range)
  PlaySoundFromCoord(-1,name,x+0.0001,y+0.0001,z+0.0001,dict,0,range+0.0001,0)
end

-- play sound
function Base:playSound(dict,name)
  PlaySound(-1,name,dict,0,0,1)
end

-- TUNNEL

function Base.tunnel:setUserId(user_id)
  self.user_id = user_id
end

function Base.tunnel:getUserId()
  return self.user_id
end

function Base.tunnel:addPlayer(player)
  self.players[player] = true
end

function Base.tunnel:removePlayer(player)
  self.players[player] = nil
end

Base.tunnel.teleport = Base.teleport
Base.tunnel.getPosition = Base.getPosition
Base.tunnel.isInside = Base.isInside
Base.tunnel.getSpeed = Base.getSpeed
Base.tunnel.getNearestPlayers = Base.getNearestPlayers
Base.tunnel.getNearestPlayer = Base.getNearestPlayer
Base.tunnel.notify = Base.notify
Base.tunnel.notifyPicture = Base.notifyPicture
Base.tunnel.playScreenEffect = Base.playScreenEffect
Base.tunnel.stopScreenEffect = Base.stopScreenEffect
Base.tunnel.playAnim = Base.playAnim
Base.tunnel.stopAnim = Base.stopAnim
Base.tunnel.setRagdoll = Base.setRagdoll
Base.tunnel.playSpatializedSound = Base.playSpatializedSound
Base.tunnel.playSound = Base.playSound

--[[
-- not working
function tvRP.setMovement(dict)
  if dict then
    SetPedMovementClipset(GetPlayerPed(-1),dict,true)
  else
    ResetPedMovementClipset(GetPlayerPed(-1),true)
  end
end
--]]

vRP:registerExtension(Base)
