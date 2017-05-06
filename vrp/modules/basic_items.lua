-- define some basic inventory items

-- DRINKS --
-- create Water item
local water_choices = {}
water_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"water",1) then
      vRP.varyThirst(user_id,-25)
      vRPclient.notify(player,{"~b~ Drinking water."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("water","Water bottle","",water_choices)

-- create Milk item
local milk_choices = {}
milk_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"milk",1) then
      vRP.varyThirst(user_id,-5)
      vRPclient.notify(player,{"~b~ Drinking Milk."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("milk","Milk","",milk_choices)
-- create Coffee item
local coffee_choices = {}
coffee_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"coffee",1) then
      vRP.varyThirst(user_id,-10)
      vRPclient.notify(player,{"~b~ Drinking Coffee."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("coffee","Coffee","",coffee_choices)

-- create Tea item
local tea_choices = {}
tea_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"tea",1) then
      vRP.varyThirst(user_id,-15)
      vRPclient.notify(player,{"~b~ Drinking Tea."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("tea","Tea","",tea_choices)

-- create iceTea item
local icetea_choices = {}
icetea_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"icetea",1) then
      vRP.varyThirst(user_id,-20)
      vRPclient.notify(player,{"~b~ Drinking ice-Tea."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("icetea","ice-Tea","",icetea_choices)

-- create Orange Juice item
local orangejuice_choices = {}
orangejuice_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"orangejuice",1) then
      vRP.varyThirst(user_id,-25)
      vRPclient.notify(player,{"~b~ Drinking Orange Juice."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("orangejuice","Orange Juice.","",orangejuice_choices)

-- create Goca Gola item
local gocagola_choices = {}
gocagola_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"gocagola",1) then
      vRP.varyThirst(user_id,-35)
      vRPclient.notify(player,{"~b~ Drinking Goca Gola."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("gocagola","Goca Gola","",gocagola_choices)

-- create RedGull item
local redgull_choices = {}
redgull_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"redgull",1) then
      vRP.varyThirst(user_id,-40)
      vRPclient.notify(player,{"~b~ Drinking RedGull."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("redgull","RedGull","",redgull_choices)

-- create Lemon limonad item
local lemonlimonad_choices = {}
lemonlimonad_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"lemonlimonad",1) then
      vRP.varyThirst(user_id,-45)
      vRPclient.notify(player,{"~b~ Drinking Lemon limonad."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("lemonlimonad","Lemon limonad","",lemonlimonad_choices)

-- create Vodka item
local vodka_choices = {}
vodka_choices["Drink"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"vodka",1) then
      vRP.varyThirst(user_id,-65)
      vRP.varyHunger(user_id, 15)
      vRPclient.notify(player,{"~b~ Drinking Vodka."})
      vRPclient.playUpperAnim(player,{"mp_player_intdrink","loop_bottle",false})
      vRP.closeMenu(player)
    end
  end
end}
vRP.defInventoryItem("vodka","Vodka","",vodka_choices)


--FOOD

-- create Breed item
local breed_choices = {}
breed_choices["Eat"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"breed",1) then
      vRP.varyHunger(user_id,-10)
      vRPclient.notify(player,{"~o~ Eating Breed."})
      vRP.closeMenu(player)
    end
  end
end}

vRP.defInventoryItem("breed","Breed","",breed_choices)

-- create Donut item
local donut_choices = {}
donut_choices["Eat"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"donut",1) then
      vRP.varyHunger(user_id,-15)
      vRPclient.notify(player,{"~o~ Eating Donut."})
      vRP.closeMenu(player)
    end
  end
end}

vRP.defInventoryItem("donut","Donut","",donut_choices)

-- create Tacos item
local tacos_choices = {}
tacos_choices["Eat"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"tacos",1) then
      vRP.varyHunger(user_id,-25)
      vRPclient.notify(player,{"~o~ Eating Tacos."})
      vRP.closeMenu(player)
    end
  end
end}

vRP.defInventoryItem("tacos","Tacos","",tacos_choices)

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

-- create Kebab item
local kebab_choices = {}
kebab_choices["Eat"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"kebab",1) then
      vRP.varyHunger(user_id,-45)
      vRPclient.notify(player,{"~o~ Eating Kebab."})
      vRP.closeMenu(player)
    end
  end
end}

vRP.defInventoryItem("kebab","Kebab","",kebab_choices)

-- create Premium Donut item
local pdonut_choices = {}
pdonut_choices["Eat"] = {function(player,choice)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil then
    if vRP.tryGetInventoryItem(user_id,"pdonut",1) then
      vRP.varyHunger(user_id,-25)
      vRPclient.notify(player,{"~o~ Eating Premium Donut."})
      vRP.closeMenu(player)
    end
  end
end}

vRP.defInventoryItem("pdonut","Premium Donut","",pdonut_choices)

-- load config items
local cfg = require("resources/vrp/cfg/items")

for k,v in pairs(cfg.items) do
  vRP.defInventoryItem(k,v[1],v[2],v[3])
end
