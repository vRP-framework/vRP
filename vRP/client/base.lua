
RegisterNetEvent("vRP:teleport")
AddEventHandler("vRP:teleport",function(x,y,z)
  SetEntityCoords(GetPlayerPed(-1), x, y, z, 1,0,0,0)
  TriggerServerEvent("vRP:updatePos",x,y,z)
end)

RegisterNetEvent("vRP:notify")
AddEventHandler("vRP:notify",function(msg)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(msg)
  DrawNotification(true, false)
end)

AddEventHandler("playerSpawned",function()
  TriggerServerEvent("vRP:playerSpawned")
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(30000)
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
    TriggerServerEvent("vRP:updatePos",x,y,z)
  end
end)
