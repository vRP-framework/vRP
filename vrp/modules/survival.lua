local cfg = require("resources/vrp/cfg/survival")

-- api

function vRP.getHunger(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.hunger
  end

  return 0
end

function vRP.getThirst(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    return data.thirst
  end

  return 0
end

function vRP.setHunger(user_id,value)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.hunger = value
    if data.hunger < 0 then data.hunger = 0
    elseif data.hunger > 100 then data.hunger = 100 
    end
  end
end

function vRP.setThirst(user_id,value)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = value
    if data.thirst < 0 then data.thirst = 0
    elseif data.thirst > 100 then data.thirst = 100 
    end
  end
end

function vRP.varyHunger(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.hunger = data.hunger + variation
    if data.hunger < 0 then data.hunger = 0
    elseif data.hunger > 100 then data.hunger = 100 
    end
  end
end

function vRP.varyThirst(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = data.thirst + variation
    if data.thirst < 0 then data.thirst = 0
    elseif data.thirst > 100 then data.thirst = 100 
    end
  end
end

-- tasks

-- hunger/thirst increase
function task_update()
  for k,v in pairs(vRP.users) do
    vRP.varyHunger(v,cfg.hunger_per_minute)
    vRP.varyThirst(v,cfg.thirst_per_minute)

    -- todo: damages
    if vRP.getHunger(v) >= 100 then
    end

    if vRP.getThirst(v) >= 100 then
    end
  end

  SetTimeout(60000,task_update)
end
task_update()

-- handlers

-- init values
AddEventHandler("vRP:playerJoin",function(user_id,source,name)
  local data = vRP.getUserDataTable(user_id)
  if data.hunger == nil then
    data.hunger = 0
    data.thirst = 0
  end
end)


