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
      TaskPlayAnim(GetPlayerPed(-1),dict,name,8.00001,-8.00001,-1,49,8.00001,0,0,0)

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

-- events

AddEventHandler("playerSpawned",function()
  TriggerServerEvent("vRP:playerSpawned")
end)

AddEventHandler("onPlayerDied",function(player,reason)
  TriggerServerEvent("vRP:playerDied")
end)

AddEventHandler("onPlayerKilled",function(player,killer,reason)
  TriggerServerEvent("vRP:playerDied")
end)



