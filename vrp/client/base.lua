tvRP = {}

-- bind client tunnel interface
Tunnel.bindInterface("vRP",tvRP)

-- get server interface
vRPserver = Tunnel.getInterface("vRP","vRP")

-- add client proxy interface (same as tunnel interface)
Proxy.addInterface("vRP",tvRP)

-- functions

function tvRP.teleport(x,y,z)
  SetEntityCoords(GetPlayerPed(-1), x, y, z, 1,0,0,1)
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

function tvRP.getNearestPlayers(radius)
  local r = {}

  local ped = GetPlayerPed(i)
  local pid = PlayerId()
  local px,py,pz = tvRP.getPosition()

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
local upper_anims = {}
local upper_anim_ids = Tools.newIDGenerator()

-- play upper anim (player can move, only the upper part is animated)
-- dict,name: see http://docs.ragepluginhook.net/html/62951c37-a440-478c-b389-c471230ddfc5.htm
-- looping: if true, will play the anim forever until stopUpperAnim is called or another upper anim is played
function tvRP.playUpperAnim(dict,name,looping)
  tvRP.stopUpperAnim()

  Citizen.CreateThread(function()
    -- request anim dict
    RequestAnimDict(dict)
    local i = 0
    while not HasAnimDictLoaded(dict) and i < 1000 do -- max time, 10 seconds
      Citizen.Wait(10)
      RequestAnimDict(dict)
      i = i+1
    end

    -- play anim
    if HasAnimDictLoaded(dict) then
      TaskPlayAnim(GetPlayerPed(-1),dict,name,8.00001,-8.00001,-1,48,0,0,0,0)

      local id = upper_anim_ids:gen()
      upper_anims[id] = true

      while (GetEntityAnimCurrentTime(GetPlayerPed(-1),dict,name) <= 0.99 or looping) and upper_anims[id] do
        Citizen.Wait(0)
      end

      upper_anim_ids:free(id)
      ClearPedSecondaryTask(GetPlayerPed(-1))
    end
  end)
end

-- stop the upper animation
function tvRP.stopUpperAnim()
  upper_anims = {} -- empty upper anims
  ClearPedSecondaryTask(GetPlayerPed(-1))
end

-- play full anim (player can't move until the animation finish)
-- dict,name: see http://docs.ragepluginhook.net/html/62951c37-a440-478c-b389-c471230ddfc5.htm
function tvRP.playFullAnim(dict,name)
  Citizen.CreateThread(function()
    -- request anim dict
    RequestAnimDict(dict)
    local i = 0
    while not HasAnimDictLoaded(dict) and i < 1000 do -- max time, 10 seconds
      Citizen.Wait(10)
      RequestAnimDict(dict)
      i = i+1
    end

    -- play anim
    if HasAnimDictLoaded(dict) then
      TaskPlayAnim(GetPlayerPed(-1),dict,name,8.00001,-8.00001,-1,9,8.00001,0,0,0)

      while GetEntityAnimCurrentTime(GetPlayerPed(-1),dict,name) <= 0.99 do
        Citizen.Wait(0)
      end

      ClearPedTasks(GetPlayerPed(-1))
    end
  end)
end

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

-- events

AddEventHandler("playerSpawned",function()
  NetworkSetTalkerProximity(cfg.voice_proximity+0.0001)
  TriggerServerEvent("vRP:playerSpawned")
end)

AddEventHandler("onPlayerDied",function(player,reason)
  TriggerServerEvent("vRP:playerDied")
end)

AddEventHandler("onPlayerKilled",function(player,killer,reason)
  TriggerServerEvent("vRP:playerDied")
end)



