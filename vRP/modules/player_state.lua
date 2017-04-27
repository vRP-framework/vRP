
-- client -> server events
RegisterServerEvent("vRP:playerSpawned")
AddEventHandler("vRP:playerSpawned", function()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    local data = vRP.getUserDataTable(user_id)
    if data ~= nil then
      if data.position ~= nil then -- teleport to saved pos
        vRP.teleport(source,data.position.x,data.position.y,data.position.z)
      end
    end
  end
end)

RegisterServerEvent("vRP:updatePos")
AddEventHandler("vRP:updatePos", function(x,y,z)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    local data = vRP.getUserDataTable(user_id)
    if data ~= nil then
      data.position = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
    end
  end
end)
