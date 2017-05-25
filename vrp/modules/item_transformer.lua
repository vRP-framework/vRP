
-- this module define a generic system to transform (generate, process, convert) items and money to other items or money in a specific area
-- each transformer can take things to generate other things, using a unit of work
-- units are generated periodically at a specific rate
-- reagents => products (reagents can be nothing, as for an harvest transformer)

local cfg = require("resources/vrp/cfg/item_transformers")
local cfg_inventory = require("resources/vrp/cfg/inventory")
local lang = vRP.lang

-- api

local transformers = {}

local function tr_remove_player(tr,player) -- remove player from transforming
  tr.players[player] = nil -- dereference player
  vRPclient.removeProgressBar(player,{"vRP:tr:"..tr.name})
  vRP.closeMenu(player)
end

local function tr_add_player(tr,player) -- add player to transforming
  tr.players[player] = true -- reference player as using transformer
  vRP.closeMenu(player)
  vRPclient.setProgressBar(player,{"vRP:tr:"..tr.name,"center",tr.itemtr.action.."...",tr.itemtr.r,tr.itemtr.g,tr.itemtr.b,0})
end

local function tr_tick(tr) -- do transformer tick
  for k,v in pairs(tr.players) do
    local user_id = vRP.getUserId(tonumber(k))
    if v and user_id ~= nil then -- for each player transforming
      if tr.units > 0 then -- check units
        -- check reagents
        local reagents_ok = true
        for l,w in pairs(tr.itemtr.reagents) do
          reagents_ok = reagents_ok and (vRP.getInventoryItemAmount(user_id,l) >= w)
        end

        -- check money
        local money_ok = (vRP.getMoney(user_id) >= tr.itemtr.in_money)

        -- weight check
        local witems = {}
        for k,v in pairs(tr.itemtr.products) do
          witems[k] = {amount=v}
        end
        local new_weight = vRP.getInventoryWeight(user_id)+vRP.computeItemsWeight(witems)

        local inventory_ok = true
        if new_weight > cfg_inventory.inventory_weight then
          inventory_ok = false
          vRPclient.notify(tonumber(k), {lang.inventory.full()})
        end

        if money_ok and reagents_ok and inventory_ok then -- do transformation
          tr.units = tr.units-1 -- sub work unit

          -- consume reagents
          if tr.itemtr.in_money > 0 then vRP.tryPayment(user_id,tr.itemtr.in_money) end
          for l,w in pairs(tr.itemtr.reagents) do
            vRP.tryGetInventoryItem(user_id,l,w)
          end

          -- produce products
          if tr.itemtr.out_money > 0 then vRP.giveMoney(user_id,tr.itemtr.out_money) end
          for l,w in pairs(tr.itemtr.products) do
            vRP.giveInventoryItem(user_id,l,w)
          end
        end
      end
    end
  end

  -- display transformation state to all transforming players
  for k,v in pairs(tr.players) do
    vRPclient.setProgressBarValue(k,{"vRP:tr:"..tr.name,math.floor(tr.units/tr.itemtr.max_units*100.0)})
    
    if tr.units > 0 then -- display units left
      vRPclient.setProgressBarText(k,{"vRP:tr:"..tr.name,tr.itemtr.action.."... "..tr.units.."/"..tr.itemtr.max_units})
    else
      vRPclient.setProgressBarText(k,{"vRP:tr:"..tr.name,"empty"})
    end
  end
end

local function bind_tr_area(player,tr) -- add tr area to client
  vRP.setArea(player,"vRP:tr:"..tr.name,tr.itemtr.x,tr.itemtr.y,tr.itemtr.z,tr.itemtr.radius,tr.itemtr.height,tr.enter,tr.leave)
end

local function unbind_tr_area(player,tr) -- remove tr area from client
  vRP.removeArea(player,"vRP:tr:"..tr.name)
end

-- add an item transformer
-- name: transformer id name
-- itemtr: item transformer definition table
--- name
--- max_units
--- units_per_minute
--- x,y,z,radius,height (area properties)
--- r,g,b (color)
--- action
--- description
--- in_money
--- out_money
--- reagents: items as idname => amount
--- products: items as idname => amount
function vRP.setItemTransformer(name,itemtr)
  vRP.removeItemTransformer(name) -- remove pre-existing transformer

  local tr = {itemtr=itemtr}
  tr.name = name
  transformers[name] = tr

  -- init transformer
  tr.units = 0
  tr.players = {}

  -- build menu
  tr.menu = {name=itemtr.name,css={top="75px",header_color="rgba("..itemtr.r..","..itemtr.g..","..itemtr.b..",0.75)"}}

  local info = "<br /><br />"
  if itemtr.in_money > 0 then info = info.."- "..itemtr.in_money end
  for k,v in pairs(itemtr.reagents) do
    local item = vRP.items[k]
    if item then
      info = info.."<br />"..v.." "..item.name
    end
  end
  info = info.."<br /><span style=\"color: rgb(0,255,125)\">=></span>"
  if itemtr.out_money > 0 then info = info.."<br />+ "..itemtr.out_money end
  for k,v in pairs(itemtr.products) do
    local item = vRP.items[k]
    if item then
      info = info.."<br />"..v.." "..item.name
    end
  end

  tr.menu[itemtr.action] = {function(player,choice) tr_add_player(tr,player) end, itemtr.description..info}

  -- build area
  tr.enter = function(player,area)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil and (itemtr.permission == nil or vRP.hasPermission(user_id,itemtr.permission)) then
      vRP.openMenu(player, tr.menu) -- open menu
    end
  end

  tr.leave = function(player,area)
    tr_remove_player(tr, player)
  end

  -- bind tr area to all already spawned players
  for k,v in pairs(vRP.rusers) do
    local source = vRP.getUserSource(k)
    if source ~= nil then
      bind_tr_area(source,tr)
    end
  end
end

-- remove an item transformer
function vRP.removeItemTransformer(name)
  local tr = transformers[name]
  if tr then
    -- copy players (to remove while iterating)
    local players = {}
    for k,v in pairs(tr.players) do
      players[k] = v
    end

    for k,v in pairs(players) do -- remove players from transforming
      tr_remove_player(tr,k)
    end

    -- remove tr area from all already spawned players
    for k,v in pairs(vRP.rusers) do
      local source = vRP.getUserSource(k)
      if source ~= nil then
        unbind_tr_area(source,tr)
      end
    end

    transformers[name] = nil
  end
end

-- task: transformers ticks (every 3 seconds)
local function transformers_tick()
  for k,tr in pairs(transformers) do
    tr_tick(tr)
  end

  SetTimeout(3000,transformers_tick)
end
transformers_tick()

-- task: transformers unit regeneration
local function transformers_regen()
  for k,tr in pairs(transformers) do
    tr.units = tr.units+tr.itemtr.units_per_minute
    if tr.units >= tr.itemtr.max_units then tr.units = tr.itemtr.max_units end
  end

  SetTimeout(60000,transformers_regen)
end
transformers_regen()

-- add transformers areas on player first spawn
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    for k,tr in pairs(transformers) do
      bind_tr_area(source,tr)
    end
  end
end)

-- STATIC TRANSFORMERS

SetTimeout(5000,function()
  -- delayed to wait items loading
  -- load item transformers from config file
  for k,v in pairs(cfg.item_transformers) do
    vRP.setItemTransformer("cfg:"..k,v)
  end
end)

-- HIDDEN TRANSFORMERS

-- generate a random position for the hidden transformer
local function gen_random_position(positions)
  local n = #positions
  if n > 0 then
    return positions[math.random(1,n)]
  else 
    return {0,0,0}
  end
end

local function hidden_placement_tick()
  local hidden_trs = json.decode(vRP.getSData("vRP:hidden_trs")) or {}

  for k,v in pairs(cfg.hidden_transformers) do
    -- init entry
    local htr = hidden_trs[k]
    if htr == nil then
      hidden_trs[k] = {timestamp=cast(int,os.time()), position=gen_random_position(v.positions)}
      htr = hidden_trs[k]
    end

    -- remove hidden transformer if needs respawn
    if tonumber(os.time())-htr.timestamp >= cfg.hidden_transformer_duration*60 then
      htr.timestamp = cast(int,os.time())
      vRP.removeItemTransformer("cfg:"..k)
      -- generate new position
      htr.position = gen_random_position(v.positions)
    end

    -- spawn if unspawned 
    if transformers["cfg:"..k] == nil then
      v.def.x = htr.position[1]
      v.def.y = htr.position[2]
      v.def.z = htr.position[3]

      vRP.setItemTransformer("cfg:"..k, v.def)
    end
  end

  vRP.setSData("vRP:hidden_trs",json.encode(hidden_trs)) -- save hidden transformers

  SetTimeout(300000, hidden_placement_tick)
end
SetTimeout(5000, hidden_placement_tick) -- delayed to wait items loading

-- INFORMER

-- build informer menu
local informer_menu = {name=lang.itemtr.informer.title(), css={top="75px",header_color="rgba(0,255,125,0.75)"}}

local function ch_informer_buy(player,choice)
  local user_id = vRP.getUserId(player)
  local tr = transformers["cfg:"..choice]
  local price = cfg.informer.infos[choice]

  if user_id ~= nil and tr ~= nil then
    if vRP.tryPayment(user_id, price) then
      vRPclient.setGPS(player, {tr.itemtr.x,tr.itemtr.y}) -- set gps marker
      vRPclient.notify(player, {lang.money.paid({price})})
      vRPclient.notify(player, {lang.itemtr.informer.bought()})
    else
      vRPclient.notify(player, {lang.money.not_enough()})
    end
  end
end

for k,v in pairs(cfg.informer.infos) do
  informer_menu[k] = {ch_informer_buy, lang.itemtr.informer.description({v})}
end

local function informer_enter()
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    vRP.openMenu(source,informer_menu) 
  end
end

local function informer_leave()
  vRP.closeMenu(source)
end

local function informer_placement_tick()
  local pos = gen_random_position(cfg.informer.positions)
  local x,y,z = table.unpack(pos)

  for k,v in pairs(vRP.rusers) do
    local player = vRP.getUserSource(tonumber(k))

    -- add informer blip/marker/area
    vRPclient.setNamedBlip(player,{"vRP:informer",x,y,z,cfg.informer.blipid,cfg.informer.blipcolor,lang.itemtr.informer.title()})
    vRPclient.setNamedMarker(player,{"vRP:informer",x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})
    vRP.setArea(player,"vRP:informer",x,y,z,1,1.5,informer_enter,informer_leave)
  end

  -- remove informer blip/marker/area after after a while
  SetTimeout(cfg.informer.duration*60000, function()
    for k,v in pairs(vRP.rusers) do
      local player = vRP.getUserSource(tonumber(k))
      vRPclient.removeNamedBlip(player,{"vRP:informer"})
      vRPclient.removeNamedMarker(player,{"vRP:informer"})
      vRP.removeArea(player,"vRP:informer")
    end
  end)

  SetTimeout(cfg.informer.interval*60000, informer_placement_tick)
end
SetTimeout(cfg.informer.interval*60000,informer_placement_tick)
