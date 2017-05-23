
-- this module describe the home system (experimental, a lot can happen and not being handled)

local lang = vRP.lang
local cfg = require("resources/vrp/cfg/homes")

-- sql

local q_init = vRP.sql:prepare([[
CREATE TABLE IF NOT EXISTS vrp_user_homes(
  user_id INTEGER,
  home VARCHAR(255),
  number INTEGER,
  CONSTRAINT pk_user_homes PRIMARY KEY(user_id),
  CONSTRAINT fk_user_homes_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE,
  UNIQUE(home,number)
);
]])
q_init:execute()

local q_get_address = vRP.sql:prepare("SELECT home, number FROM vrp_user_homes WHERE user_id = @user_id")
local q_get_owner = vRP.sql:prepare("SELECT user_id FROM vrp_user_homes WHERE home = @home AND number = @number")
local q_rm_address = vRP.sql:prepare("DELETE FROM vrp_user_homes WHERE user_id = @user_id")
local q_set_address = vRP.sql:prepare("REPLACE INTO vrp_user_homes(user_id,home,number) VALUES(@user_id,@home,@number)")

-- api

local instances = {}

-- return user address (home and number) or nil
function vRP.getUserAddress(user_id)
  local address = nil

  q_get_address:bind("@user_id",user_id)
  local r = q_get_address:query()
  if r:fetch() then
    address = r:getRow()
  end

  r:close()

  return address
end

-- set user address
function vRP.setUserAddress(user_id,home,number)
  q_set_address:bind("@user_id",user_id)
  q_set_address:bind("@home",home)
  q_set_address:bind("@number",number)

  q_set_address:execute()
end

-- remove user address
function vRP.removeUserAddress(user_id)
  q_rm_address:bind("@user_id",user_id)
  q_rm_address:execute()
end

-- return user_id or nil
function vRP.getUserByAddress(home,number)
  local user_id = nil
  
  q_get_owner:bind("@home",home)
  q_get_owner:bind("@number",number)
  local r = q_get_owner:query()
  if r:fetch() then
    user_id = r:getValue(0)
  end
  r:close()

  return user_id
end

-- find a free address number to buy
-- return number or nil if no numbers availables
function vRP.findFreeNumber(home,max)
  for i=1,max do
    if vRP.getUserByAddress(home,i) == nil then
      return i
    end
  end

  return nil
end

-- SLOTS

-- used (or not) slots
local uslots = {}
for k,v in pairs(cfg.slot_types) do
  uslots[k] = {}
  for l,w in pairs(v) do
    uslots[k][l] = {used=false}
  end
end

-- return slot id or nil if no slot available
local function allocateSlot(stype)
  local slots = cfg.slot_types[stype]
  if slots then
    local _uslots = uslots[stype]
    -- search the first unused slot
    for k,v in pairs(slots) do
      if _uslots[k] and not _uslots[k].used then 
        _uslots[k].used = true -- set as used
        return k  -- return slot id
      end
    end
  end

  return nil
end

-- free a slot
local function freeSlot(stype, id)
  local slots = cfg.slot_types[stype]
  if slots then
    uslots[stype][id] = {used = false} -- reset as unused
  end
end

-- get in use address slot (not very optimized yet)
-- return slot_type, slot_id or nil,nil
local function getAddressSlot(home_name,number)
  for k,v in pairs(uslots) do
    for l,w in pairs(v) do
      if w.home_name == home_name and tostring(w.home_number) == tostring(number) then
        return k,l
      end
    end
  end

  return nil,nil
end

-- builds

local function is_empty(table)
  for k,v in pairs(table) do
    return false
  end

  return true
end

-- leave slot
local function leave_slot(user_id,player,stype,sid) -- called when a player leave a slot
  print(user_id.." leave slot "..stype.." "..sid)
  local slot = uslots[stype][sid]
  local home = cfg.homes[slot.home_name]
  
  -- teleport to home entry point (outside)
  vRPclient.teleport(player, home.entry_point) -- already an array of params (x,y,z)

  -- uncount player
  slot.players[user_id] = nil

  -- remove marker/area
  local nid = "vRP:home:slot"..stype..sid
  vRPclient.removeNamedMarker(player,{nid})
  vRP.removeArea(player,nid)

  if is_empty(slot.players) then -- free the slot
    freeSlot(stype,sid)
  end
end

-- enter slot
local function enter_slot(user_id,player,stype,sid) -- called when a player enter a slot
  print(user_id.." enter slot "..stype.." "..sid)
  local slot = uslots[stype][sid]
  local slot_entry = cfg.slot_types[stype][sid]
  local home = cfg.homes[slot.home_name]

  local x,y,z = table.unpack(slot_entry)
  -- teleport to the slot entry point
  vRPclient.teleport(player, slot_entry) -- already an array of params (x,y,z)

  -- count
  slot.players[user_id] = player

  -- build the slot entry menu
  local menu = {name=slot.home_name,css={top="75px",header_color="rgba(0,255,125,0.75)"}}
  menu[lang.home.slot.leave.title()] = {function(player,choice) -- add leave choice
    leave_slot(user_id,player,stype,sid)
  end}

  local address = vRP.getUserAddress(user_id)

  -- check if owner
  if address ~= nil and address.home == slot.home_name and tostring(address.number) == slot.home_number then 
    menu[lang.home.slot.ejectall.title()] = {function(player,choice) -- add eject all choice
      -- copy players before calling leave for each (iteration while removing)
      local copy = {}
      for k,v in pairs(slot.players) do
        copy[k] = v
      end

      for k,v in pairs(copy) do
        leave_slot(k,v,stype,sid)
      end
    end,lang.home.slot.ejectall.description()}
  end

  -- build the slot entry menu marker/area

  local function entry_enter(player,area)
    vRP.openMenu(player,menu)
  end

  local function entry_leave(player,area)
    vRP.closeMenu(player)
  end

  local nid = "vRP:home:slot"..stype..sid
  vRPclient.setNamedMarker(player,{nid,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})
  vRP.setArea(player,nid,x,y,z,1,1.5,entry_enter,entry_leave)
end

-- access a home by address
-- return true on success
function vRP.accessHome(user_id, home, number)
  local _home = cfg.homes[home]
  local stype,slotid = getAddressSlot(home,number) -- get current address slot
  local player = vRP.getUserSource(user_id)

  if _home ~= nil and player ~= nil then
    if stype == nil then -- allocate a new slot
      stype = _home.slot
      slotid = allocateSlot(_home.slot)
      
      if slotid ~= nil then -- allocated, set slot home infos
        local slot = uslots[stype][slotid]
        slot.home_name = home
        slot.home_number = number
        slot.players = {} -- map user_id => player
      end
    end

    if slotid ~= nil then -- slot available
      enter_slot(user_id,player,stype,slotid)
      return true
    end
  end

  return false
end

-- build the home entry menu
local function build_entry_menu(user_id, home_name)
  local home = cfg.homes[home_name]
  local menu = {name=home_name,css={top="75px",header_color="rgba(0,255,125,0.75)"}}

  -- intercom, used to enter in a home
  menu[lang.home.intercom.title()] = {function(player,choice)
    vRP.prompt(player, lang.home.intercom.prompt(), "", function(player,number)
      local huser_id = vRP.getUserByAddress(home_name,tonumber(number or 0))
      if huser_id ~= nil then
        if huser_id == user_id then -- identify owner (direct home access)
          if not vRP.accessHome(user_id, home_name, number) then
            vRPclient.notify(player,{lang.home.intercom.not_available()})
          end
        else -- try to access home by asking owner
          local hplayer = vRP.getUserSource(huser_id)
          if hplayer ~= nil then
            vRP.prompt(player,lang.home.intercom.prompt_who(),"",function(player,who)
              vRPclient.notify(player,{lang.home.intercom.asked()})
              -- request owner to open the door
              vRP.request(hplayer, lang.home.intercom.request({who}), 30, function(hplayer,ok)
                if ok then
                  vRP.accessHome(user_id, home_name, number)
                else
                  vRPclient.notify(player,{lang.home.intercom.refused()})
                end
              end)
            end)
          else
            vRPclient.notify(player,{lang.home.intercom.refused()})
          end
        end
      else
        vRPclient.notify(player,{lang.common.not_found()})
      end
    end)
  end,lang.home.intercom.description()}

  menu[lang.home.buy.title()] = {function(player,choice)
    if vRP.getUserAddress(user_id) == nil then -- check if not already have a home
      local number = vRP.findFreeNumber(home_name, home.max)
      if number ~= nil then
        if vRP.tryPayment(user_id, home.buy_price) then
          -- bought, set address
          vRP.setUserAddress(user_id, home_name, number)

          vRPclient.notify(player,{lang.home.buy.bought()})
        else
          vRPclient.notify(player,{lang.money.not_enough()})
        end
      else
        vRPclient.notify(player,{lang.home.buy.full()})
      end
    else
      vRPclient.notify(player,{lang.home.buy.have_home()})
    end
  end, lang.home.buy.description({home.buy_price})}

  menu[lang.home.sell.title()] = {function(player,choice)
    local address = vRP.getUserAddress(user_id)
    if address ~= nil and address.home == home_name then -- check if already have a home
      -- sold, give sell price, remove address
      vRP.giveMoney(user_id, home.sell_price)
      vRP.removeUserAddress(user_id)
      vRPclient.notify(player,{lang.home.sell.sold()})
    else
      vRPclient.notify(player,{lang.home.sell.no_home()})
    end
  end, lang.home.sell.description({home.sell_price})}

  return menu
end

-- build homes entry points
local function build_client_homes(source)
  local user_id = vRP.getUserId(source)
  if user_id ~= nil then
    for k,v in pairs(cfg.homes) do
      local x,y,z = table.unpack(v.entry_point)

      local function entry_enter(player,area)
        local user_id = vRP.getUserId(player)
        if user_id ~= nil and (v.permission == nil or vRP.hasPermission(user_id,v.permission)) then
          vRP.openMenu(source,build_entry_menu(user_id, k))
        end
      end

      local function entry_leave(player,area)
        vRP.closeMenu(player)
      end

      vRPclient.addBlip(source,{x,y,z,v.blipid,v.blipcolor,k})
      vRPclient.addMarker(source,{x,y,z-1,0.7,0.7,0.5,0,255,125,125,150})

      vRP.setArea(source,"vRP:home"..k,x,y,z,1,1.5,entry_enter,entry_leave)
    end
  end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then -- first spawn, build homes
    build_client_homes(source)
  end
end)
