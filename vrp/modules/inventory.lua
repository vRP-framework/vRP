local lang = vRP.lang

-- this module define the player inventory (lost after respawn, as wallet)

vRP.items = {}

-- define an inventory item (call this at server start)
-- idname: unique item name
-- name: display name
-- description: item description (html)
-- choices: menudata choices (see gui api)
function vRP.defInventoryItem(idname,name,description,choices)
  local item = {name=name,description=description,choices=choices}
  vRP.items[idname] = item

  -- build item menu
  item.menudata = {name=name,css={top="75px",header_color="rgba(0,125,255,0.75)"}}

  -- add defined choices
  for k,v in pairs(choices) do
    item.menudata[k] = v
  end

  -- add give action
  item.menudata[lang.inventory.give.title()] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
      -- get nearest player
      vRPclient.getNearestPlayer(player,{10},function(nplayer)
        if nplayer ~= nil then
          local nuser_id = vRP.getUserId(nplayer)
          if nuser_id ~= nil then
            -- prompt number
            vRP.prompt(player,lang.inventory.give.prompt({vRP.getInventoryItemAmount(user_id,idname)}),"",function(player,amount)
              local amount = tonumber(amount)
              if vRP.tryGetInventoryItem(user_id,idname,amount) then
                vRP.giveInventoryItem(nuser_id,idname,amount)
                vRPclient.notify(player,{lang.inventory.give.given({name,amount})})
                vRPclient.notify(nplayer,{lang.inventory.give.received({name,amount})})
              else
                vRPclient.notify(player,{lang.common.invalid_value()})
              end
            end)
          else
            vRPclient.notify(player,{lang.common.no_player_near()})
          end
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      end)
    end
  end,lang.inventory.give.description()}
end

-- add item to a connected user inventory
function vRP.giveInventoryItem(user_id,idname,amount)
  local data = vRP.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry then -- add to entry
      entry.amount = entry.amount+amount
    else -- new entry
      data.inventory[idname] = {amount=amount}
    end
  end
end

-- try to get item from a connected user inventory
function vRP.tryGetInventoryItem(user_id,idname,amount)
  local data = vRP.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry and entry.amount >= amount then -- add to entry
      entry.amount = entry.amount-amount

      -- remove entry if <= 0
      if entry.amount <= 0 then
        data.inventory[idname] = nil 
      end
      return true
    end
  end

  return false
end

-- get user inventory amount of item
function vRP.getInventoryItemAmount(user_id,idname)
  local data = vRP.getUserDataTable(user_id)
  if data and data.inventory then
    local entry = data.inventory[idname]
    if entry then
      return entry.amount
    end
  end

  return 0
end

-- clear connected user inventory
function vRP.clearInventory(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data then
    data.inventory = {}
  end
end

-- INVENTORY MENU

-- open player inventory
function vRP.openInventory(source)
  local user_id = vRP.getUserId(source)

  if user_id ~= nil then
    local data = vRP.getUserDataTable(user_id)
    if data then
      -- build inventory menu
      local menudata = {name=lang.inventory.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}
      local kitems = {}

      -- choose callback, nested menu, create the item menu
      local choose = function(player,choice)
        local item = vRP.items[kitems[choice]]
        if item then
          -- copy item menu
          local submenudata = {}
          for k,v in pairs(item.menudata) do
            submenudata[k] = v
          end

          -- nest menu
          submenudata.onclose = function()
            vRP.openInventory(source) -- reopen inventory when submenu closed
          end

          -- open menu
          vRP.openMenu(source,submenudata)
        end
      end

      -- add each item to the menu
      for k,v in pairs(data.inventory) do 
        local item = vRP.items[k]
        if item then
          kitems[item.name] = k -- reference item by display name
          menudata[item.name] = {choose,lang.inventory.iteminfo({v.amount,item.description})}
        end
      end

      -- open menu
      vRP.openMenu(source,menudata)
    end
  end
end

-- init inventory
AddEventHandler("vRP:playerJoin", function(user_id,source,name,last_login)
  local data = vRP.getUserDataTable(user_id)
  if data.inventory == nil then
    data.inventory = {}
  end
end)


-- add open inventory to main menu
local choices = {}
choices[lang.inventory.title()] = {function(player, choice) vRP.openInventory(player) end, lang.inventory.description()}

AddEventHandler("vRP:buildMainMenu", function(player) vRP.buildMainMenu(player,choices) end)
