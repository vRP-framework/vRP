
local htmlEntities = module("vrp", "lib/htmlEntities")

local lang = vRP.lang

-- this module define the player inventory
local Inventory = class("Inventory", vRP.Extension)

-- SUBCLASS

Inventory.User = class("User")

-- return map of fullid => amount
function Inventory.User:getInventory()
  return self.cdata.inventory
end

function Inventory.User:giveItem(fullid,amount,no_notify)
  if amount > 0 then
    local inventory = self:getInventory()

    local i_amount = inventory[fullid] or 0
    inventory[fullid] = i_amount+amount

    -- notify
    if not no_notify then
      local citem = vRP.EXT.Inventory:computeItem(fullid)
      if citem then
        vRP.EXT.Base.remote._notify(self.source,lang.inventory.give.received({citem.name,amount}))
      end
    end
  end
end

-- try to get an item from inventory
-- return true on success or false
function Inventory.User:tryGetItem(fullid,amount,no_notify)
  if amount > 0 then
    local inventory = self:getInventory()

    local i_amount = inventory[fullid] or 0
    if i_amount >= amount then -- add to entry
      local new_amount = i_amount-amount
      if new_amount > 0 then
        inventory[fullid] = new_amount
      else
        inventory[fullid] = nil
      end

      -- notify
      if no_notify then
        local citem = vRP.EXT.Inventory:computeItem(fullid)
        if citem then
          vRP.EXT.Base.remote._notify(self.source,lang.inventory.give.given({citem.name,amount}))
        end
      end

      return true
    else
      -- notify
      if no_notify then
        local citem = vRP.EXT.Inventory:computeItem(fullid)
        if citem then
          vRP.EXT.Base.remote._notify(self.source,lang.inventory.missing({citem.name,amount-i_amount}))
        end
      end
    end
  end

  return false
end

-- get item amount in the inventory
function Inventory.User:getItemAmount(fullid)
  local data = vRP.getUserDataTable(user_id)
  local inventory = self:getInventory()

  return inventory[fullid] or 0
end

-- return inventory total weight
function Inventory.User:getInventoryWeight()
  return vRP.EXT.Inventory:computeItemsWeight(self:getInventory())
end

-- return maximum weight of inventory
function Inventory.User:getInventoryMaxWeight()
--  return math.floor(vRP.expToLevel(vRP.getExp(user_id, "physical", "strength")))*cfg.inventory_weight_per_strength
  return 30
end

function Inventory.User:clearInventory()
  self.cdata.inventory = {}
end

-- STATIC

-- PRIVATE METHODS

-- menu: inventory item
local function menu_inventory_item(self)
  -- give action
  local function m_give(menu)
    local user = menu.user
    local fullid = menu.data.fullid
    local citem = self:computeItem(fullid)

    -- get nearest player
    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source, 10)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      -- prompt number
      local amount = parseInt(user:prompt(lang.inventory.give.prompt({user:getItemAmount(fullid)}),""))

      -- weight check
      local new_weight = nuser:getInventoryWeight()+citem.weight*amount
      if new_weight <= nuser:getInventoryMaxWeight() then
        if user:tryGetItem(fullid,amount) then
          nuser:giveItem(fullid,amount)
          user:actualizeMenu()

          vRP.EXT.Base.remote._playAnim(user.source,true,{{"mp_common","givetake1_a",1}},false)
          vRP.EXT.Base.remote._playAnim(nuser.source,true,{{"mp_common","givetake2_a",1}},false)
        else
          vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.inventory.full())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  -- trash action
  local function m_trash(menu)
    local user = menu.user
    local fullid = menu.data.fullid
    local citem = self:computeItem(fullid)

    -- prompt number
    local amount = parseInt(user:prompt(lang.inventory.trash.prompt({user:getItemAmount(fullid)}),""))
    if user:tryGetItem(fullid,amount,true) then
      user:actualizeMenu()
      vRP.EXT.Base.remote._notify(user.source,lang.inventory.trash.done({citem.name,amount}))
      vRP.EXT.Base.remote._playAnim(user.source,true,{{"pickup_object","pickup_low",1}},false)
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("inventory.item", function(menu)
    menu.css.header_color="rgba(0,125,255,0.75)"

    local user = menu.user
    local citem = self:computeItem(menu.data.fullid)
    if citem then
      menu.title = htmlEntities.encode(citem.name.." ("..user:getItemAmount(menu.data.fullid)..")")
    end

    -- item menu builder
    if citem.menu_builder then
      citem.menu_builder(citem.args, menu)
    end

    -- add give/trash options
    menu:addOption(lang.inventory.give.title(), m_give, lang.inventory.give.description())
    menu:addOption(lang.inventory.trash.title(), m_trash, lang.inventory.trash.description())
  end)
end

-- menu: inventory
local function menu_inventory(self)
  local function m_item(menu, value)
    menu.user:openMenu("inventory.item", {fullid = value})
  end

  vRP.EXT.GUI:registerMenuBuilder("inventory", function(menu)
    menu.title = lang.inventory.title()
    menu.css.header_color="rgba(0,125,255,0.75)"

    local user = menu.user

    -- add inventory info
    local weight = user:getInventoryWeight()
    local max_weight = user:getInventoryMaxWeight()

    local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
    menu:addOption("<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>", nil, lang.inventory.info_weight({string.format("%.2f", weight), max_weight}))

    local inventory = user:getInventory()

    -- add each item to the menu
    for fullid, amount in pairs(data.inventory) do 
      local citem = self:computeItem(fullid)
      if citem then
        menu:addOption(htmlEntities.encode(citem.name), m_item, lang.inventory.iteminfo({amount,citem.description, string.format("%.2f",citem.weight)}), fullid)
      end
    end
  end)
end

-- METHODS

function Inventory:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/inventory")
  self.items = {}

  -- menu

  menu_inventory_item(self)
  menu_inventory(self)

  local function m_inventory(menu)
    menu.user:openMenu("inventory")
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption(lang.inventory.title(), m_inventory, lang.inventory.description())
  end)
end

-- define an inventory item (parametric or plain text data)
-- id: unique item identifier (string)
-- name: display name, value or genfunction(args)
-- description: value or genfunction(args) (html)
-- menu_builder: (optional) genfunction(args, menu)
-- weight: (optional) value or genfunction(args)
--
-- genfunction are functions returning a correct value as: function(args, ...)
-- where args is a list of {base_idname,args...}
function Inventory:defineItem(id,name,description,menu_builder,weight)
  self.items[id] = {name=name,description=description,menu_builder=menu_builder,weight=weight}
end


function Inventory:parseItem(fullid)
  return splitString(fullid,"|")
end

-- return computed item or nil
-- computed item
--- name
--- description
--- weight
--- menu_builder: can be nil
--- args: parametric args
function Inventory:computeItem(fullid)
  local args = self:parseItem(fullid)
  local item = self.items[args[1]]
  if item then
    -- name
    local name
    if type(item.name) == "string" then
      name = item.name
    elseif item.name then
      name = item.name(args)
    end

    if not name then name = fullid end

    -- description
    local desc
    if type(item.description) == "string" then
      desc = item.description
    elseif item.description then
      desc = item.description(args)
    end

    if not desc then desc = "" end

    -- weight
    local weight
    if type(item.weight) == "number" then
      weight = item.weight
    elseif item.weight then
      weight = item.weight(args)
    end

    if not weight then weight = 0 end

    return {name=name, description=desc, weight=weight, menu_builder = item.menu_builder, args = args}
  end
end

-- compute weight of a list of items (in inventory/chest format)
function Inventory:computeItemsWeight(items)
  local weight = 0

  for fullid, item in pairs(items) do
    local citem = self:computeItem(fullid)
    weight = weight+(citem and citem.weight or 0)*item.amount
  end

  return weight
end

-- EVENT
Inventory.event = {}

function Inventory.event:characterLoad(user)
  if not user.cdata.inventory then
    user.cdata.inventory = {}
  end
end

-- INVENTORY MENU

-- open player inventory
function vRP.openInventory(source)
  local user_id = vRP.getUserId(source)

  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data then
    end
  end
end

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
      cb(idname)
    end
  end

  -- add each item to the menu
  for k,v in pairs(items) do 
    local name,description,weight = vRP.getItemDefinition(k)
    if name then
      kitems[name] = k -- reference item by display name
      menu[name] = {choose,lang.inventory.iteminfo({v.amount,description,string.format("%.2f", weight)})}
    end
  end

  return menu
end

-- open a chest by name
-- cb_close(): called when the chest is closed (optional)
-- cb_in(idname, amount): called when an item is added (optional)
-- cb_out(idname, amount): called when an item is taken (optional)
function vRP.openChest(source, name, max_weight, cb_close, cb_in, cb_out)
  local user_id = vRP.getUserId(source)
  if user_id then
    local data = vRP.getUserDataTable(user_id)
    if data.inventory then
      if not chests[name] then
        local close_count = 0 -- used to know when the chest is closed (unlocked)

        -- load chest
        local chest = {max_weight = max_weight}
        chests[name] = chest 
        local cdata = vRP.getSData("chest:"..name)
        chest.items = json.decode(cdata) or {} -- load items

        -- open menu
        local menu = {name=lang.inventory.chest.title(), css={top="75px",header_color="rgba(0,255,125,0.75)"}}
        -- take
        local cb_take = function(idname)
          local citem = chest.items[idname]
          local amount = vRP.prompt(source, lang.inventory.chest.take.prompt({citem.amount}), "")
          amount = parseInt(amount)
          if amount >= 0 and amount <= citem.amount then
            -- take item

            -- weight check
            local new_weight = vRP.getInventoryWeight(user_id)+vRP.getItemWeight(idname)*amount
            if new_weight <= vRP.getInventoryMaxWeight(user_id) then
              vRP.giveInventoryItem(user_id, idname, amount, true)
              citem.amount = citem.amount-amount

              if citem.amount <= 0 then
                chest.items[idname] = nil -- remove item entry
              end

              if cb_out then cb_out(idname,amount) end

              -- actualize by closing
              vRP.closeMenu(source)
            else
              vRPclient._notify(source,lang.inventory.full())
            end
          else
            vRPclient._notify(source,lang.common.invalid_value())
          end
        end

        local ch_take = function(player, choice)
          local submenu = build_itemlist_menu(lang.inventory.chest.take.title(), chest.items, cb_take)
          -- add weight info
          local weight = vRP.computeItemsWeight(chest.items)
          local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
          submenu["<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>"] = {function()end, lang.inventory.info_weight({string.format("%.2f",weight),max_weight})}


          submenu.onclose = function()
            close_count = close_count-1
            vRP.openMenu(player, menu)
          end
          close_count = close_count+1
          vRP.openMenu(player, submenu)
        end


        -- put
        local cb_put = function(idname)
          local amount = vRP.prompt(source, lang.inventory.chest.put.prompt({vRP.getInventoryItemAmount(user_id, idname)}), "")
          amount = parseInt(amount)

          -- weight check
          local new_weight = vRP.computeItemsWeight(chest.items)+vRP.getItemWeight(idname)*amount
          if new_weight <= max_weight then
            if amount >= 0 and vRP.tryGetInventoryItem(user_id, idname, amount, true) then
              local citem = chest.items[idname]

              if citem ~= nil then
                citem.amount = citem.amount+amount
              else -- create item entry
                chest.items[idname] = {amount=amount}
              end

              -- callback
              if cb_in then cb_in(idname,amount) end

              -- actualize by closing
              vRP.closeMenu(source)
            end
          else
            vRPclient._notify(source,lang.inventory.chest.full())
          end
        end

        local ch_put = function(player, choice)
          local submenu = build_itemlist_menu(lang.inventory.chest.put.title(), data.inventory, cb_put)
          -- add weight info
          local weight = vRP.computeItemsWeight(data.inventory)
          local max_weight = vRP.getInventoryMaxWeight(user_id)
          local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
          submenu["<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>"] = {function()end, lang.inventory.info_weight({string.format("%.2f",weight),max_weight})}

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
        vRPclient._notify(source,lang.inventory.chest.already_opened())
      end
    end
  end
end

-- STATIC CHESTS

local function build_client_static_chests(source)
  local user_id = vRP.getUserId(source)
  if user_id then
    for k,v in pairs(cfg.static_chests) do
      local mtype,x,y,z = table.unpack(v)
      local schest = cfg.static_chest_types[mtype]

      if schest then
        local function schest_enter(source)
          local user_id = vRP.getUserId(source)
          if user_id ~= nil and vRP.hasPermissions(user_id,schest.permissions or {}) then
            -- open chest
            vRP.openChest(source, "static:"..k, schest.weight or 0)
          end
        end

        local function schest_leave(source)
          vRP.closeMenu(source)
        end

        vRPclient._addBlip(source,x,y,z,schest.blipid,schest.blipcolor,schest.title)
        vRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,255,226,0,125,150)

        vRP.setArea(source,"vRP:static_chest:"..k,x,y,z,1,1.5,schest_enter,schest_leave)
      end
    end
  end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    -- load static chests
    build_client_static_chests(source)
  end
end)


