
-- define some basic inventory items

-- WATER BOTTLE

-- create Water bottle item
local wb_choices = {}
wb_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"water_bottle",1) then
      vRP.varyThirst(user_id,-35)
      vRPclient.notify(player,{"~b~ Drinking water."})
      vRP.closeMenu(player)
    end
  end
end}

vRP.defInventoryItem("water_bottle","Water bottle","Drinkable water in a bottle.",wb_choices)

--SANDWICH

-- create sandwich item
local sd_choices = {}
sd_choices["Eat"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"sandwich",1) then
      vRP.varyHunger(user_id,-25)
      vRPclient.notify(player,{"~o~ Eating sandwich."})
      vRP.closeMenu(player)
    end
  end
end}

vRP.defInventoryItem("sandwich","Sandwich","A tasty snack.",sd_choices)
