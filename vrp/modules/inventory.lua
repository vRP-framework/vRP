local lang = vRP.lang
local cfg = require("resources/vrp/cfg/inventory")

-- this module define the player inventory (lost after respawn, as wallet)

vRP.items = {}

-- define an inventory item (call this at server start)
-- idname: unique item name
-- name: display name
-- description: item description (html)
-- choices: menudata choices (see gui api)
function vRP.defInventoryItem(idname,name,description,choices,weight)
  if weight == nil then
    weight = 0
  end

  local item = {name=name,description=description,choices=choices,weight=weight}
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
              -- weight check
              local new_weight = vRP.getInventoryWeight(nuser_id)+vRP.items[idname].weight*amount
              if new_weight <= cfg.inventory_weight then
                if vRP.tryGetInventoryItem(user_id,idname,amount) then
                  vRP.giveInventoryItem(nuser_id,idname,amount)
                  vRPclient.notify(player,{lang.inventory.give.given({name,amount})})
                  vRPclient.notify(nplayer,{lang.inventory.give.received({name,amount})})
                else
                  vRPclient.notify(player,{lang.common.invalid_value()})
                end
              else
                vRPclient.notify(player,{lang.inventory.full()})
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

  -- add trash action
  item.menudata[lang.inventory.trash.title()] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
      -- prompt number
      vRP.prompt(player,lang.inventory.trash.prompt({vRP.getInventoryItemAmount(user_id,idname)}),"",function(player,amount)
        local amount = tonumber(amount)
        if vRP.tryGetInventoryItem(user_id,idname,amount) then
          vRPclient.notify(player,{lang.inventory.trash.done({name,amount})})
        else
          vRPclient.notify(player,{lang.common.invalid_value()})
        end
      end)
    end
  end,lang.inventory.trash.description()}
end

-- compute weight of a list of items (in inventory/chest format)
function vRP.computeItemsWeight(items)
  local weight = 0

  for k,v in pairs(items) do
    local item = vRP.items[k]
    if item ~= nil then
      weight = weight+item.weight*v.amount
    end
  end

  return weight
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

-- return user inventory total weight
function vRP.getInventoryWeight(user_id)
  local data = vRP.getUserDataTable(user_id)
  if data and data.inventory then
    return vRP.computeItemsWeight(data.inventory)
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
      -- add inventory info
      menudata["@ "..lang.inventory.info_weight({vRP.getInventoryWeight(user_id), cfg.inventory_weight})] = {function()end}
      local kitems = {}

      -- choose callback, nested menu, create the item menu
      local choose = function(player,choice)
        if string.sub(choice,1,1) ~= "@" then -- ignore info choices
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
      end

      -- add each item to the menu
      for k,v in pairs(data.inventory) do 
        local item = vRP.items[k]
        if item then
          kitems[item.name] = k -- reference item by display name
          menudata[item.name] = {choose,lang.inventory.iteminfo({v.amount,item.description,item.weight})}
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

-- CHEST SYSTEM

local chests = {}

-- build a menu from a list of items and bind a callback(idname)
local function build_itemlist_menu(name, items, cb)
  local menu = {name=name, css={top="75px",header_color="rgba(0,255,125,0.75)"}}

  local kitems = {}

  -- choice callback
  local choose = function(player,choice)
    local idname = kitems[choice]
    if idname then
      local item = vRP.items[idname]
      if item then
        cb(idname)
      end
    end
  end

  -- add each item to the menu
  for k,v in pairs(items) do 
    local item = vRP.items[k]
    if item then
      kitems[item.name] = k -- reference item by display name
      menu[item.name] = {choose,lang.inventory.iteminfo({v.amount,item.description,item.weight})}
    end
  end

  return menu
end

-- open a chest by name
-- cb_close(): called when the chest is closed
-- cb_in(idname, amount): called when an item is added
-- cb_out(idname, amount): called when an item is taken
function vRP.openChest(source, name, max_weight, cb_close, cb_in, cb_out)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    local data = vRP.getUserDataTable(user_id)
    if data.inventory ~= nil then
      if not chests[name] then
        local close_count = 0 -- used to know when the chest is closed (unlocked)

        -- load chest
        local chest = {max_weight = max_weight}
        chests[name] = chest 
        chest.items = json.decode(vRP.getSData("chest:"..name)) or {} -- load items

        -- open menu
        local menu = {name=lang.inventory.chest.title(), css={top="75px",header_color="rgba(0,255,125,0.75)"}}
        -- take
        local cb_take = function(idname)
          local citem = chest.items[idname]
          vRP.prompt(source, lang.inventory.chest.take.prompt({citem.amount}), "", function(player, amount)
            amount = tonumber(amount)
            if amount >= 0 and amount <= citem.amount then
              -- take item
              
              -- weight check
              local new_weight = vRP.getInventoryWeight(user_id)+vRP.items[idname].weight*amount
              if new_weight <= cfg.inventory_weight then
                vRP.giveInventoryItem(user_id, idname, amount)
                citem.amount = citem.amount-amount

                if citem.amount <= 0 then
                  chest.items[idname] = nil -- remove item entry
                end

                if cb_out then cb_out(idname,amount) end

                -- actualize by closing
                vRP.closeMenu(player)
              else
                vRPclient.notify(source,{lang.inventory.full()})
              end
            else
              vRPclient.notify(source,{lang.common.invalid_value()})
            end
          end)
        end

        local ch_take = function(player, choice)
          local submenu = build_itemlist_menu(lang.inventory.chest.take.title(), chest.items, cb_take)
          -- add weight info
          submenu["@ "..lang.inventory.info_weight({vRP.computeItemsWeight(chest.items),max_weight})] = {function() end}

          submenu.onclose = function() 
            close_count = close_count-1
            vRP.openMenu(player, menu) 
          end
          close_count = close_count+1
          vRP.openMenu(player, submenu)
        end


        -- put
        local cb_put = function(idname)
          vRP.prompt(source, lang.inventory.chest.put.prompt({vRP.getInventoryItemAmount(user_id, idname)}), "", function(player, amount)
            amount = tonumber(amount)

            -- weight check
            local new_weight = vRP.computeItemsWeight(chest.items)+vRP.items[idname].weight*amount
            if new_weight <= max_weight then
              if amount >= 0 and vRP.tryGetInventoryItem(user_id, idname, amount) then
                local citem = chest.items[idname]

                if citem ~= nil then
                  citem.amount = citem.amount+amount
                else -- create item entry
                  chest.items[idname] = {amount=amount}
                end

                -- callback
                if cb_in then cb_in(idname,amount) end

                -- actualize by closing
                vRP.closeMenu(player)
              else
                vRPclient.notify(source,{lang.common.invalid_value()})
              end
            else
              vRPclient.notify(source,{lang.inventory.chest.full()})
            end
          end)
        end

        local ch_put = function(player, choice)
          local submenu = build_itemlist_menu(lang.inventory.chest.put.title(), data.inventory, cb_put)
          -- add weight info
          submenu["@ "..lang.inventory.info_weight({vRP.computeItemsWeight(data.inventory),cfg.inventory_weight})] = {function() end}

          submenu.onclose = function() 
            close_count = close_count-1
            vRP.openMenu(player, menu) 
          end
          close_count = close_count+1
          vRP.openMenu(player, submenu)
        end


        -- choices
        menu[lang.inventory.chest.take.title()] = {ch_take}
        menu[lang.inventory.chest.put.title()] = {ch_put}

        menu.onclose = function()
          if close_count == 0 then -- close chest
            -- save chest items
            vRP.setSData("chest:"..name, json.encode(chest.items))
            chests[name] = nil
            if cb_close then cb_close() end -- close callback
          end
        end

        -- open menu
        vRP.openMenu(source, menu)
      else
        vRPclient.notify(source,{lang.inventory.chest.already_opened()})
      end
    end
  end
end
