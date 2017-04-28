tvRP = {}
Tunnel.bindInterface("vRP",tvRP)
vRPtun = Tunnel.getInterface("vRP","vRP")

function tvRP.teleport(x,y,z)
  SetEntityCoords(GetPlayerPed(-1), x, y, z, 1,0,0,0)
  vRPtun.updatePos({x,y,z})
end

function tvRP.notify(msg)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(msg)
  DrawNotification(true, false)
end

AddEventHandler("playerSpawned",function()
  TriggerServerEvent("vRP:playerSpawned")
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(30000)
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    vRPtun.updatePos({x,y,z})
  end
end)
