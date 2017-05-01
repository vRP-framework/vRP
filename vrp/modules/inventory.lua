
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

  for k,v in pairs(choices) do
    item.menudata[k] = v
  end
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
      local menudata = {name="Inventory",css={top="75px",header_color="rgba(0,125,255,0.75)"}}
      local kitems = {}

      -- choose callback, nested menu, create the item menu
      local choose = function(player,choice)
        local item = vRP.items[kitems[choice]]
        if item then
          -- copy menu
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
          menudata[item.name] = {choose,"("..v.amount..")<br /><br />"..item.description}
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
choices["Inventory"] = {function(player, choice) vRP.openInventory(player) end, "Open the inventory."}

AddEventHandler("vRP:buildMainMenu", function(player) vRP.buildMainMenu(player,choices) end)
