-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.inventory then return end

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

-- try to give an item
-- dry: if passed/true, will not affect
-- return true on success or false
function Inventory.User:tryGiveItem(fullid,amount,dry,no_notify)
  if amount > 0 then
    local inventory = self:getInventory()
    local citem = vRP.EXT.Inventory:computeItem(fullid)
    if citem then
      local i_amount = inventory[fullid] or 0

      -- weight check
      local new_weight = self:getInventoryWeight()+citem.weight*amount
      if new_weight <= self:getInventoryMaxWeight() then
        if not dry then
          inventory[fullid] = i_amount+amount

          -- notify
          if not no_notify then
            vRP.EXT.Base.remote._notify(self.source,lang.inventory.give.received({citem.name,amount}))
          end
        end

        return true
      end
    end
  end

  return false
end

-- try to take an item from inventory
-- dry: if passed/true, will not affect
-- return true on success or false
function Inventory.User:tryTakeItem(fullid,amount,dry,no_notify)
  if amount > 0 then
    local inventory = self:getInventory()

    local i_amount = inventory[fullid] or 0
    if i_amount >= amount then -- add to entry
      if not dry then
        local new_amount = i_amount-amount
        if new_amount > 0 then
          inventory[fullid] = new_amount
        else
          inventory[fullid] = nil
        end

        -- notify
        if not no_notify then
          local citem = vRP.EXT.Inventory:computeItem(fullid)
          if citem then
            vRP.EXT.Base.remote._notify(self.source,lang.inventory.give.given({citem.name,amount}))
          end
        end
      end

      return true
    else
      -- notify
      if not dry and not no_notify then
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
  local inventory = self:getInventory()
  return inventory[fullid] or 0
end

-- return inventory total weight
function Inventory.User:getInventoryWeight()
  return vRP.EXT.Inventory:computeItemsWeight(self:getInventory())
end

-- return maximum weight of inventory
function Inventory.User:getInventoryMaxWeight()
  return math.floor(vRP.EXT.Aptitude:expToLevel(self:getExp("physical", "strength")))*vRP.EXT.Inventory.cfg.inventory_weight_per_strength
end

function Inventory.User:clearInventory()
  self.cdata.inventory = {}
end

-- chest menu remove event
local function e_chest_remove(menu)
  -- unload chest

  if menu.data.cb_close then
    menu.data.cb_close(menu.data.id)
  end

  vRP.EXT.Inventory:unloadChest(menu.data.id)
end

-- open a chest by identifier (GData)
-- cb_close(id): called when the chest is closed (optional)
-- cb_in(chest_id, fullid, amount): called when an item is added (optional)
-- cb_out(chest_id, fullid, amount): called when an item is taken (optional)
-- return chest menu or nil
function Inventory.User:openChest(id, max_weight, cb_close, cb_in, cb_out)
  if not vRP.EXT.Inventory.chests[id] then -- not already loaded
    local chest = vRP.EXT.Inventory:loadChest(id)
    local menu = self:openMenu("chest", {id = id, chest = chest, max_weight = max_weight, cb_close = cb_close, cb_in = cb_in, cb_out = cb_out})

    menu:listen("remove", e_chest_remove)

    return menu
  else
    vRP.EXT.Base.remote._notify(self.source, lang.inventory.chest.already_opened())
  end
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

      if nuser:tryGiveItem(fullid,amount,true) then
        if user:tryTakeItem(fullid,amount,true) then
          user:tryTakeItem(fullid, amount)
          nuser:tryGiveItem(fullid, amount)

          if user:getItemAmount(fullid) > 0 then
            user:actualizeMenu()
          else
            user:closeMenu(menu)
          end

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
    if user:tryTakeItem(fullid,amount,nil,true) then
      if user:getItemAmount(fullid) > 0 then
        user:actualizeMenu()
      else
        user:closeMenu(menu)
      end

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
    for fullid, amount in pairs(user:getInventory()) do 
      local citem = self:computeItem(fullid)
      if citem then
        menu:addOption(htmlEntities.encode(citem.name), m_item, lang.inventory.iteminfo({amount,citem.description, string.format("%.2f",citem.weight)}), fullid)
      end
    end
  end)
end

-- menu: chest take
local function menu_chest_take(self)
  local function m_take(menu, fullid)
    local user = menu.user
    local chest = menu.data.chest

    local i_amount = chest[fullid] or 0
    local amount = parseInt(user:prompt(lang.inventory.chest.take.prompt({i_amount}), ""))
    if amount >= 0 and amount <= i_amount then
      if user:tryGiveItem(fullid, amount) then
        local new_amount = i_amount-amount

        if new_amount > 0 then
          chest[fullid] = new_amount
        else
          chest[fullid] = nil
        end

        if menu.data.cb_out then menu.data.cb_out(menu.data.id, fullid, amount) end

        user:actualizeMenu()
      else
        vRP.EXT.Base.remote._notify(user.source,lang.inventory.full())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("chest.take", function(menu)
    menu.title = lang.inventory.chest.take.title()
    menu.css.header_color = "rgba(0,255,125,0.75)"

    -- add weight info
    local weight = self:computeItemsWeight(menu.data.chest)
    local hue = math.floor(math.max(125*(1-weight/menu.data.max_weight), 0))
    menu:addOption("<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/menu.data.max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>", nil, lang.inventory.info_weight({string.format("%.2f",weight),menu.data.max_weight}))

    -- add chest items
    for fullid,amount in pairs(menu.data.chest) do
      local citem = self:computeItem(fullid)
      menu:addOption(htmlEntities.encode(citem.name), m_take, lang.inventory.iteminfo({amount,citem.description,string.format("%.2f", citem.weight)}), fullid)
    end
  end)
end

-- menu: chest put
local function menu_chest_put(self)
  local function m_put(menu, fullid)
    local user = menu.user
    local chest = menu.data.chest

    local citem = self:computeItem(fullid)

    if citem then
      local i_amount = user:getItemAmount(fullid)
      local amount = parseInt(user:prompt(lang.inventory.chest.put.prompt({i_amount}), ""))
      if amount >= 0 and amount <= i_amount and user:tryTakeItem(fullid, amount, true) then
        local new_amount = (chest[fullid] or 0)+amount

        -- chest weight check
        local new_weight = self:computeItemsWeight(chest)+citem.weight*amount
        if new_weight <= menu.data.max_weight then
          if new_amount > 0 then
            chest[fullid] = new_amount
          else
            chest[fullid] = nil
          end

          if menu.data.cb_in then menu.data.cb_in(menu.data.id, fullid, amount) end

          user:tryTakeItem(fullid, amount)
          user:actualizeMenu()
        else
          vRP.EXT.Base.remote._notify(user.source,lang.inventory.chest.full())
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("chest.put", function(menu)
    menu.title = lang.inventory.chest.put.title()
    menu.css.header_color = "rgba(0,255,125,0.75)"

    -- add weight info
    local weight = menu.user:getInventoryWeight()
    local max_weight = menu.user:getInventoryMaxWeight()
    local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
    menu:addOption("<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>", nil, lang.inventory.info_weight({string.format("%.2f",weight),max_weight}))

    -- add user items
    for fullid,amount in pairs(menu.user:getInventory()) do
      local citem = self:computeItem(fullid)
      if citem then
        menu:addOption(htmlEntities.encode(citem.name), m_put, lang.inventory.iteminfo({amount,citem.description,string.format("%.2f", citem.weight)}), fullid)
      end
    end
  end)
end

-- menu: chest
local function menu_chest(self)
  local function m_take(menu)
    local smenu = menu.user:openMenu("chest.take", menu.data) -- pass menu chest data
    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  local function m_put(menu)
    local smenu = menu.user:openMenu("chest.put", menu.data) -- pass menu chest data
    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  vRP.EXT.GUI:registerMenuBuilder("chest", function(menu)
    menu.title = lang.inventory.chest.title()
    menu.css.header_color="rgba(0,255,125,0.75)"

    menu:addOption(lang.inventory.chest.take.title(), m_take)
    menu:addOption(lang.inventory.chest.put.title(), m_put)
  end)
end

-- menu: admin users user
local function menu_admin_users_user(self)
  local function m_giveitem(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      local fullid = user:prompt(lang.admin.users.user.give_item.prompt(),"")
      local amount = parseInt(user:prompt(lang.admin.users.user.give_item.prompt_amount(),""))
      if not tuser:tryGiveItem(fullid, amount) then
        vRP.EXT.Base.remote._notify(user.source, lang.admin.users.user.give_item.notify_failed())
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      if user:hasPermission("player.giveitem") then
        menu:addOption(lang.admin.users.user.give_item.title(), m_giveitem)
      end
    end
  end)
end

-- METHODS

function Inventory:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/inventory")

  self.items = {} -- item definitions
  self.computed_items = {} -- computed item definitions
  self.chests = {} -- loaded chests

  -- special item permission
  local function fperm_item(user, params)
    if #params == 3 then -- decompose item.operator
      local item = params[2]
      local op = params[3]

      local amount = user:getItemAmount(item)

      local fop = string.sub(op,1,1)
      if fop == "<" then  -- less (item.<x)
        local n = parseInt(string.sub(op,2,string.len(op)))
        if amount < n then return true end
      elseif fop == ">" then -- greater (item.>x)
        local n = parseInt(string.sub(op,2,string.len(op)))
        if amount > n then return true end
      else -- equal (item.x)
        local n = parseInt(string.sub(op,1,string.len(op)))
        if amount == n then return true end
      end
    end
  end

  vRP.EXT.Group:registerPermissionFunction("item", fperm_item)

  -- menu

  menu_inventory_item(self)
  menu_inventory(self)
  menu_chest(self)
  menu_chest_take(self)
  menu_chest_put(self)
  menu_admin_users_user(self)

  local function m_inventory(menu)
    menu.user:openMenu("inventory")
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption(lang.inventory.title(), m_inventory, lang.inventory.description())
  end)

  -- define config items
  local cfg_items = module("cfg/items")
  for id,v in pairs(cfg_items.items) do
    self:defineItem(id,v[1],v[2],v[3],v[4])
  end

  -- transformer processor

  vRP.EXT.Transformer:registerProcessor("items", function(user, reagents, products) -- on display
    local r_info = ""
    if reagents then
      for fullid,amount in pairs(reagents) do
        local citem = vRP.EXT.Inventory:computeItem(fullid)
        if citem then
          r_info = r_info..lang.inventory.transformer_recipe({citem.name, amount})
        end
      end
    end

    local p_info = ""

    if products then
      for fullid,amount in pairs(products) do
        local citem = vRP.EXT.Inventory:computeItem(fullid)
        if citem then
          p_info = p_info..lang.inventory.transformer_recipe({citem.name, amount})
        end
      end
    end

    return r_info, p_info
  end, function(user, reagents, products) -- on check
    local ok = true

    if reagents then
      for fullid,amount in pairs(reagents) do
        ok = ok and (user:getItemAmount(fullid) >= amount)

        if not ok then
          local citem = self:computeItem(fullid)
          vRP.EXT.Base.remote._notify(user.source, lang.inventory.missing({citem.name, amount-user:getItemAmount(fullid)}))
          break
        end
      end
    end

    if ok and products then
      local new_weight = user:getInventoryWeight()-self:computeItemsWeight(reagents or {})+self:computeItemsWeight(products)
      ok = (new_weight <= user:getInventoryMaxWeight())

      if not ok then
        vRP.EXT.Base.remote._notify(user.source, lang.inventory.full())
      end
    end

    return ok
  end, function(user, reagents, products) -- on process
    if reagents then
      for fullid,amount in pairs(reagents) do
        user:tryTakeItem(fullid,amount)
      end
    end

    if products then
      for fullid,amount in pairs(products) do
        user:tryGiveItem(fullid,amount)
      end
    end
  end)
end

-- define an inventory item (parametric or plain text data)
-- id: unique item identifier (string, no "." or "|")
-- name: display name, value or genfunction(args)
-- description: value or genfunction(args) (html)
-- menu_builder: (optional) genfunction(args, menu)
-- weight: (optional) value or genfunction(args)
--
-- genfunction are functions returning a correct value as: function(args, ...)
-- where args is a list of {base_idname,args...}
function Inventory:defineItem(id,name,description,menu_builder,weight)
  if self.items[id] then
    self:log("WARNING: re-defined item \""..id.."\"")
  end

  self.items[id] = {name=name,description=description,menu_builder=menu_builder,weight=weight}
end


function Inventory:parseItem(fullid)
  return splitString(fullid,"|")
end

-- compute item definition (cached)
-- return computed item or nil
-- computed item {}
--- name
--- description
--- weight
--- menu_builder: can be nil
--- args: parametric args
function Inventory:computeItem(fullid)
  local citem = self.computed_items[fullid]

  if not citem then -- compute
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

      citem = {name=name, description=desc, weight=weight, menu_builder = item.menu_builder, args = args}
      self.computed_items[fullid] = citem
    end
  end

  return citem
end

-- compute weight of a list of items (in inventory/chest format)
function Inventory:computeItemsWeight(items)
  local weight = 0

  for fullid, amount in pairs(items) do
    local citem = self:computeItem(fullid)
    weight = weight+(citem and citem.weight or 0)*amount
  end

  return weight
end

-- load global chest
-- id: identifier (string)
-- return chest (as inventory, map of fullid => amount)
function Inventory:loadChest(id)
  local chest = self.chests[id]
  if not chest then
    local sdata = vRP:getGData("vRP:chest:"..id)
    if sdata and string.len(sdata) > 0 then
      chest = msgpack.unpack(sdata)
    end

    if not chest then chest = {} end

    self.chests[id] = chest
  end

  return chest
end

-- unload global chest
-- id: identifier (string)
function Inventory:unloadChest(id)
  local chest = self.chests[id]
  if chest then
    vRP:setGData("vRP:chest:"..id, msgpack.pack(chest))
    self.chests[id] = nil
  end
end

-- EVENT
Inventory.event = {}

function Inventory.event:characterLoad(user)
  if not user.cdata.inventory then
    user.cdata.inventory = {}
  end
end

function Inventory.event:playerDeath(user)
  if self.cfg.lose_inventory_on_death then
    user.cdata.inventory = {}
  end
end

function Inventory.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- init static chests
    for k,v in pairs(self.cfg.static_chests) do
      local mtype,x,y,z = table.unpack(v)
      local schest = self.cfg.static_chest_types[mtype]

      if schest then
        local menu
        local function enter(user)
          if user:hasPermissions(schest.permissions or {}) then
            menu = user:openChest("cfg_static:"..vRP.cfg.server_id.."_"..k, schest.weight or 0)
          end
        end

        local function leave(user)
          if menu then
            user:closeMenu(menu)
          end
        end

        local ment = clone(schest.map_entity)
        ment[2].title = schest.title
        ment[2].pos = {x,y,z-1}

        vRP.EXT.Map.remote._addEntity(user.source,ment[1],ment[2])

        user:setArea("vRP:static_chest:"..k,x,y,z,1,1.5,enter,leave)
      end
    end
  end
end

vRP:registerExtension(Inventory)
