tvRP = {}

-- bind client tunnel interface
Tunnel.bindInterface("vRP",tvRP)

-- get server interface
vRPserver = Tunnel.getInterface("vRP","vRP")

-- add client proxy interface (same as tunnel interface)
Proxy.addInterface("vRP",tvRP)

-- get client configuration
config = {}

vRPserver.getClientConfig({},function(_config)
  config = _config
end)

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

AddEventHandler("playerSpawned",function()
  TriggerServerEvent("vRP:playerSpawned")
end)

AddEventHandler("onPlayerDied",function(player,reason)
  TriggerServerEvent("vRP:playerDied")
end)

AddEventHandler("onPlayerKilled",function(player,killer,reason)
  TriggerServerEvent("vRP:playerDied")
end)



