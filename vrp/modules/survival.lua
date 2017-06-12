local cfg = require("resources/vrp/cfg/survival")
local lang = vRP.lang

-- update bars event handling

AddEventHandler("vRP:updateHunger",function(user_id,value)
  if not cfg.disable then
    local source = vRP.getUserSource(user_id)
    vRPclient.setProgressBarValue(source,{"vRP:hunger",value})
    if value >= 100 then
      vRPclient.setProgressBarText(source,{"vRP:hunger",lang.survival.starving()})
    else
      vRPclient.setProgressBarText(source,{"vRP:hunger",""})
    end
  end
end)

AddEventHandler("vRP:updateThirst",function(user_id,value)
  if not cfg.disable then
    local source = vRP.getUserSource(user_id)
    vRPclient.setProgressBarValue(source,{"vRP:thirst",value})
    if value >= 100 then
      vRPclient.setProgressBarText(source,{"vRP:thirst",lang.survival.thirsty()})
    else
      vRPclient.setProgressBarText(source,{"vRP:thirst",""})
    end
  end
end)

-- api

function vRP.normalize(value)
  if value < 0 then value = 0
  elseif value > 100 then value = 100 
  end
  return value
end

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
    data.hunger = vRP.normalize(value)

    -- update bar
    TriggerEvent("vRP:updateHunger",user_id, data.hunger)
  end
end

function vRP.setThirst(user_id,value)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = vRP.normalize(value)

    -- update bar
   TriggerEvent("vRP:updateThirst",user_id, data.thirst) 
  end
end

function vRP.varyHunger(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.hunger = data.hunger + variation
    
    -- apply overflow as damage
    local overflow = data.hunger-100
    if overflow > 0 then
      vRPclient.varyHealth(vRP.getUserSource(user_id),{-overflow*cfg.overflow_damage_factor})
    end

    data.hunger = vRP.normalize(data.hunger)

    -- set progress bar data
    TriggerEvent("vRP:updateHunger",user_id, data.hunger)
  end
end

function vRP.varyThirst(user_id, variation)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.thirst = data.thirst + variation
    
    -- apply overflow as damage
    local overflow = data.thirst-100
    if overflow > 0 then
      vRPclient.varyHealth(vRP.getUserSource(user_id),{-overflow*cfg.overflow_damage_factor})
    end

    data.thirst = vRP.normalize(data.thirst)

    -- set progress bar data
    TriggerEvent("vRP:updateThirst",user_id, data.thirst)
  end
end

-- tunnel api (expose some functions to clients)

function tvRP.varyHunger(variation)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    vRP.varyHunger(user_id,variation)
  end
end

function tvRP.varyThirst(variation)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    vRP.varyThirst(user_id,variation)
  end
end

-- tasks

-- hunger/thirst increase
function task_update()
  for k,v in pairs(vRP.users) do
    vRP.varyHunger(v,cfg.hunger_per_minute)
    vRP.varyThirst(v,cfg.thirst_per_minute)
  end

  SetTimeout(60000,task_update)
end
task_update()

-- handlers

-- init values
AddEventHandler("vRP:playerJoin",function(user_id,source,name,last_login)
  local data = vRP.getUserDataTable(user_id)
  if data.hunger == nil then
    data.hunger = 0
    data.thirst = 0
  end
end)

-- add survival progress bars on spawn
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  local data = vRP.getUserDataTable(user_id)

  -- disable police
  vRPclient.setPolice(source,{cfg.police})
  -- set friendly fire
  vRPclient.setFriendlyFire(source,{cfg.pvp})

  if not cfg.disable then
	  vRPclient.setProgressBar(source,{"vRP:hunger","minimap",htxt,255,153,0,0})
	  vRPclient.setProgressBar(source,{"vRP:thirst","minimap",ttxt,0,125,255,0})
	  vRP.setHunger(user_id, data.hunger)
	  vRP.setThirst(user_id, data.thirst)
  end
end)

-- EMERGENCY

---- revive
local revive_seq = {
  {"amb@medic@standing@kneel@enter","enter",1},
  {"amb@medic@standing@kneel@idle_a","idle_a",1},
  {"amb@medic@standing@kneel@exit","exit",1}
}

local choice_revive = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
      local nuser_id = vRP.getUserId(nplayer)
      if nuser_id ~= nil then
        vRPclient.isInComa(nplayer,{}, function(in_coma)
          if in_coma then
            if vRP.tryGetInventoryItem(user_id,"medkit",1) then
              vRPclient.playAnim(player,{false,revive_seq,false}) -- anim
              SetTimeout(15000, function()
                vRPclient.varyHealth(nplayer,{50}) -- heal 50
              end)
            else
              vRPclient.notify(player,{lang.inventory.missing({vRP.getItemName("medkit"),1})})
            end
          else
            vRPclient.notify(player,{lang.emergency.menu.revive.not_in_coma()})
          end
        end)
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end,lang.emergency.menu.revive.description()}

-- add choices to the main menu (emergency)
AddEventHandler("vRP:buildMainMenu",function(player) 
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    local choices = {}
    if vRP.hasPermission(user_id,"emergency.revive") then
      choices[lang.emergency.menu.revive.title()] = choice_revive
    end

    vRP.buildMainMenu(player,choices)
  end
end)
