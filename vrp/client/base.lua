tvRP = {}
local players = {} -- keep track of connected players (server id)

-- bind client tunnel interface
Tunnel.bindInterface("vRP",tvRP)

-- get server interface
vRPserver = Tunnel.getInterface("vRP","vRP")

-- add client proxy interface (same as tunnel interface)
Proxy.addInterface("vRP",tvRP)

-- functions


function tvRP.teleport(x,y,z)
  SetEntityCoords(GetPlayerPed(-1), x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)
  vRPserver.updatePos({x,y,z})
end

function tvRP.getPosition()
  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
  return x,y,z
end

function tvRP.getSpeed()
  local vx,vy,vz = table.unpack(GetEntityVelocity(GetPlayerPed(-1)))
  return math.sqrt(vx*vx+vy*vy+vz*vz)
end

function tvRP.addPlayer(player)
  players[player] = true
end

function tvRP.removePlayer(player)
  players[player] = nil
end

function tvRP.getNearestPlayers(radius)
  local r = {}

  local ped = GetPlayerPed(i)
  local pid = PlayerId()
  local px,py,pz = tvRP.getPosition()

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

  for k,v in pairs(players) do
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

function tvRP.getNearestPlayer(radius)
  local p = nil

  local players = tvRP.getNearestPlayers(radius)
  local min = radius+10.0
  for k,v in pairs(players) do
    if v < min then
      min = v
      p = k
    end
  end

  return p
end

function tvRP.notify(msg)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(msg)
  DrawNotification(true, false)
end


-- ANIM

-- animations dict and names: http://docs.ragepluginhook.net/html/62951c37-a440-478c-b389-c471230ddfc5.htm

local anims = {}
local anim_ids = Tools.newIDGenerator()

-- play animation (new version)
-- upper: true, only upper body, false, full animation
-- seq: list of animations as {dict,anim_name,loops} (loops is the number of loops, default 1)
-- looping: if true, will infinitely loop the first element of the sequence until stopAnim is called
function tvRP.playAnim(upper, seq, looping)
  tvRP.stopAnim(upper)



  local flags = 0
  if upper then flags = flags+48 end
  if looping then flags = flags+1 end

  Citizen.CreateThread(function()
    -- prepare unique id to stop sequence when needed
    local id = anim_ids:gen()
    anims[id] = true

    for k,v in pairs(seq) do
      local dict = v[1]
      local name = v[2]
      local loops = v[3] or 1

      for i=1,loops do
        if anims[id] then -- check animation working
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
          if HasAnimDictLoaded(dict) and anims[id] then
            local inspeed = 8.0001
            local outspeed = -8.0001
            if not first then inspeed = 2.0001 end
            if not last then outspeed = 2.0001 end

            TaskPlayAnim(GetPlayerPed(-1),dict,name,inspeed,outspeed,-1,flags,0,0,0,0)
          end

          Citizen.Wait(0)
          while GetEntityAnimCurrentTime(GetPlayerPed(-1),dict,name) <= 0.95 and IsEntityPlayingAnim(GetPlayerPed(-1),dict,name,3) and anims[id] do
            Citizen.Wait(0)
          end
        end
      end
    end

    -- free id
    anim_ids:free(id)
    anims[id] = nil
  end)
end

-- stop animation (new version)
-- upper: true, stop the upper animation, false, stop full animations
function tvRP.stopAnim(upper)
  anims = {} -- stop all sequences
  if upper then
    ClearPedSecondaryTask(GetPlayerPed(-1))
  else
    ClearPedTasks(GetPlayerPed(-1))
  end
end

-- start anim task
function tvRP.playTask(name, anim)
  ped = GetPlayerPed(-1)
  if name == "sitchair" then
    pos = GetEntityCoords(ped)
    head = GetEntityHeading(ped)
    TaskStartScenarioAtPosition(ped, anim, pos['x'], pos['y'], pos['z'] - 1, head, 0, 0, false)
  else
    TaskStartScenarioInPlace(ped, anim, 0, true)
  end
end

-- stop anim task
function tvRP.stopTask()
  ped = GetPlayerPed(-1)
  ClearPedTasks(ped)
end

-- RAGDOLL
local ragdoll = false

-- set player ragdoll flag (true or false)
function tvRP.setRagdoll(flag)
  ragdoll = flag
end

-- ragdoll thread
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)
    if ragdoll then
      SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
    end
  end
end)

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

-- events

AddEventHandler("playerSpawned",function()
  NetworkSetTalkerProximity(cfg.voice_proximity+0.0001)
  Citizen.CreateThread(function() -- delay spawned event of 5 seconds
    Citizen.Wait(5000)
    TriggerServerEvent("vRP:playerSpawned")
  end)
end)

AddEventHandler("onPlayerDied",function(player,reason)
  TriggerServerEvent("vRP:playerDied")
end)

AddEventHandler("onPlayerKilled",function(player,killer,reason)
  TriggerServerEvent("vRP:playerDied")
end)



