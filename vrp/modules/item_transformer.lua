
-- this module define a generic system to transform (generate, process, convert) items and money to other items or money in a specific area
-- each transformer can take things to generate other things, using a unit of work
-- units are generated periodically at a specific rate
-- reagents => products (reagents can be nothing, as for an harvest transformer)

local cfg = require("resources/vrp/cfg/item_transformers")

-- api

local transformers = {}

local function tr_remove_player(tr,player) -- remove player from transforming
  tr.players[player] = nil -- dereference player
  vRPclient.removeProgressBar(player,{"vRP:tr:"..tr.name})
end

local function tr_add_player(tr,player) -- add player to transforming
  tr.players[player] = true -- reference player as using transformer
  vRP.closeMenu(player)
  vRPclient.setProgressBar(player,{"vRP:tr:"..tr.name,"center",tr.itemtr.action.."...",tr.itemtr.r,tr.itemtr.g,tr.itemtr.b,0})
end

local function tr_tick(tr) -- do transformer tick
  for k,v in pairs(tr.players) do
    local user_id = vRP.getUserId(k)
    if user_id ~= nil then -- for each player transforming
      if tr.units > 0 then -- check units
        -- check reagents
        local reagents_ok = true
        for l,w in pairs(tr.itemtr.reagents) do
          reagents_ok = reagents_ok and (vRP.getInventoryItemAmount(user_id,l) >= w)
        end

        -- check money
        local money_ok = (vRP.getMoney(user_id) >= tr.itemtr.in_money)

        -- todo: check if inventory can carry products
        local inventory_ok = true

        if money_ok and reagents_ok and inventory_ok then -- do transformation
          tr.units = tr.units-1 -- sub work unit

          -- consume reagents
          if tr.in_money > 0 then vRP.tryPayment(user_id,tr.itemtr.in_money) end
          for l,w in pairs(tr.itemtr.reagents) do
            vRP.tryGetInventoryItem(user_id,l,w)
          end

          -- produce products
          if tr.out_money > 0 then vRP.giveMoney(user_id,tr.itemtr.out_money) end
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
  tr.menu[itemtr.action] = {function(player,choice) tr_add_player(tr,player) end, itemtr.description}

  -- build area
  tr.enter = function(player,area)
    vRP.openMenu(player, tr.menu) -- open menu
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
    for k,v in pairs(tr.players) do -- remove players from transforming
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
  end

  SetTimeout(60000,transformers_regen)
end
transformers_regen()

-- add transformers areas on player first spawn
AddEventHandler("vRP:playerSpawned",function()
  local user_id = vRP.getUserId(source)
  if vRP.isFirstSpawn(user_id) then
    for k,tr in pairs(transformers) do
      bind_tr_area(source,tr)
    end
  end
end)

-- load item transformers from config file
for k,v in pairs(cfg.item_transformers) do
  vRP.setItemTransformer("cfg:"..k,v)
end
