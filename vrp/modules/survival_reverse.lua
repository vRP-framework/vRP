local cfg = require("resources/vrp/cfg/survival")
local lang = vRP.lang

AddEventHandler("vRP:playerSpawn",function(user_id, source)
  if cfg.disable then
	local data = vRP.getUserDataTable(user_id)
	vRPclient.setProgressBar(source,{"vRP:hunger","minimap",htxt,255,153,0,0})
	vRPclient.setProgressBar(source,{"vRP:thirst","minimap",ttxt,0,125,255,0})
	vRP.setHunger(user_id, data.hunger)
	vRP.setThirst(user_id, data.thirst)
  end
end)

AddEventHandler("vRP:updateHunger",function(user_id,value)
  if cfg.disable then
    local source = vRP.getUserSource(user_id)
	value = 100 - value
    vRPclient.setProgressBarValue(source,{"vRP:hunger",value})
    if value <= 0 then
      vRPclient.setProgressBarText(source,{"vRP:hunger",lang.survival.starving()})
    else
      vRPclient.setProgressBarText(source,{"vRP:hunger",""})
    end
  end
end)

AddEventHandler("vRP:updateThirst",function(user_id,value)
  if cfg.disable then
    local source = vRP.getUserSource(user_id)
	value = 100 - value
    vRPclient.setProgressBarValue(source,{"vRP:thirst",value})
    if value <= 0 then
      vRPclient.setProgressBarText(source,{"vRP:thirst",lang.survival.thirsty()})
    else
      vRPclient.setProgressBarText(source,{"vRP:thirst",""})
    end
  end
end)