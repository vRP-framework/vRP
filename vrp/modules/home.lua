
-- this module describe the home system (experimental, a lot can happen and not being handled)

local lang = vRP.lang
local cfg = module("cfg/homes")

-- sql

vRP.prepare("vRP/home_tables", [[
CREATE TABLE IF NOT EXISTS vrp_user_homes(
  user_id INTEGER,
  home VARCHAR(100),
  number INTEGER,
  CONSTRAINT pk_user_homes PRIMARY KEY(user_id),
  CONSTRAINT fk_user_homes_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE,
  UNIQUE(home,number)
);
]])

vRP.prepare("vRP/get_address","SELECT home, number FROM vrp_user_homes WHERE user_id = @user_id")
vRP.prepare("vRP/get_home_owner","SELECT user_id FROM vrp_user_homes WHERE home = @home AND number = @number")
vRP.prepare("vRP/rm_address","DELETE FROM vrp_user_homes WHERE user_id = @user_id")
vRP.prepare("vRP/set_address","REPLACE INTO vrp_user_homes(user_id,home,number) VALUES(@user_id,@home,@number)")

-- init
async(function()
  vRP.execute("vRP/home_tables")
end)

-- api

local components = {}

-- return user address (home and number) or nil
function vRP.getUserAddress(user_id, cbr)
  local rows = vRP.query("vRP/get_address", {user_id = user_id})
  return rows[1]
end

-- set user address
function vRP.setUserAddress(user_id,home,number)
  vRP.execute("vRP/set_address", {user_id = user_id, home = home, number = number})
end

-- remove user address
function vRP.removeUserAddress(user_id)
  vRP.execute("vRP/rm_address", {user_id = user_id})
end

-- return user_id or nil
function vRP.getUserByAddress(home,number,cbr)
  local rows = vRP.query("vRP/get_home_owner", {home = home, number = number})
  if #rows > 0 then
    return rows[1].user_id
  end
end

-- find a free address number to buy
-- return number or nil if no numbers availables
function vRP.findFreeNumber(home,max,cbr)
  local i = 1
  while i <= max do
    if not vRP.getUserByAddress(home,i) then
      return i
    end
    i = i+1
  end
end

-- define home component (oncreate and ondestroy are called for each player entering/leaving a slot)
-- name: unique component id
-- oncreate(owner_id, slot_type, slot_id, cid, config, data, x, y, z, player)
-- ondestroy(owner_id, slot_type, slot_id, cid, config, data, x, y, z, player)
--- owner_id: user_id of house owner
--- slot_type: slot type name
--- slot_id: slot id for a specific type
--- cid: component id (for this slot)
--- config: component config
--- data: component datatable
--- x,y,z: component position
--- player: player joining/leaving the slot
function vRP.defHomeComponent(name, oncreate, ondestroy)
  components[name] = {oncreate,ondestroy}
end

function vRP.getHomeSlotPlayers(stype, sid)
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

-- get players in the specified home slot
-- return map of user_id -> player source or nil if the slot is unavailable
function vRP.getHomeSlotPlayers(stype, sid)
  local slot = uslots[stype][sid]
  if slot and slot.used then
    return slot.players
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

  -- record if inside a home slot
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    tmp.home_stype = nil
    tmp.home_sid = nil
  end

  -- teleport to home entry point (outside)
  vRPclient._teleport(player, table.unpack(home.entry_point)) -- already an array of params (x,y,z)

  -- uncount player
  slot.players[user_id] = nil

  -- destroy loaded components and special entry component
  for k,v in pairs(cfg.slot_types[stype][sid]) do
    local name,x,y,z = table.unpack(v)

    if name == "entry" then
      -- remove marker/area
      local nid = "vRP:home:slot"..stype..sid
      vRPclient._removeNamedMarker(player,nid)
      vRP.removeArea(player,nid)
    else
      local component = components[v[1]]
      if component then
        local data = slot.components[k]
        if not data then
          data = {}
          slot.components[k] = data
        end

        -- ondestroy(owner_id, slot_type, slot_id, cid, config, data, x, y, z, player)
        component[2](slot.owner_id, stype, sid, k, v._config or {}, data, x, y, z, player)
      end
    end
  end

  if is_empty(slot.players) then -- free the slot
    print("free slot "..stype.." "..sid)
    freeSlot(stype,sid)
  end
end

-- enter slot
local function enter_slot(user_id,player,stype,sid) -- called when a player enter a slot
  print(user_id.." enter slot "..stype.." "..sid)
  local slot = uslots[stype][sid]
  local home = cfg.homes[slot.home_name]

  -- record inside a home slot
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp then
    tmp.home_stype = stype
    tmp.home_sid = sid
  end

  -- count
  slot.players[user_id] = player

  -- build the slot entry menu
  local menu = {name=slot.home_name,css={top="75px",header_color="rgba(0,255,125,0.75)"}}
  menu[lang.home.slot.leave.title()] = {function(player,choice) -- add leave choice
    leave_slot(user_id,player,stype,sid)
  end}

  local address = vRP.getUserAddress(user_id)
  -- check if owner
  if address and address.home == slot.home_name and tostring(address.number) == slot.home_number then
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

  -- build components and special entry component
  for k,v in pairs(cfg.slot_types[stype][sid]) do
    local name,x,y,z = table.unpack(v)

    if name == "entry" then
      -- teleport to the slot entry point
      vRPclient._teleport(player, x,y,z) -- already an array of params (x,y,z)

      local nid = "vRP:home:slot"..stype..sid
      vRPclient._setNamedMarker(player,nid,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)
      vRP.setArea(player,nid,x,y,z,1,1.5,entry_enter,entry_leave)
    else -- load regular component
      local component = components[v[1]]
      if component then
        local data = slot.components[k]
        if not data then
          data = {}
          slot.components[k] = data
        end

        -- oncreate(owner_id, slot_type, slot_id, cid, config, data, x, y, z, player)
        component[1](slot.owner_id, stype, sid, k, v._config or {}, data, x, y, z, player)
      end
    end
  end
end

-- access a home by address
-- return true on success
function vRP.accessHome(user_id, home, number)
  local _home = cfg.homes[home]
  local stype,slotid = getAddressSlot(home,number) -- get current address slot
  local player = vRP.getUserSource(user_id)

  local owner_id = vRP.getUserByAddress(home,number)
  if _home ~= nil and player ~= nil then
    if stype == nil then -- allocate a new slot
      stype = _home.slot
      slotid = allocateSlot(_home.slot)

      if slotid ~= nil then -- allocated, set slot home infos
        local slot = uslots[stype][slotid]
        slot.home_name = home
        slot.home_number = number
        slot.owner_id = owner_id
        slot.players = {} -- map user_id => player
        slot.components = {} -- components data
      end
    end

    if slotid ~= nil then -- slot available
      enter_slot(user_id,player,stype,slotid)
      return true
    end
  end
end

-- build the home entry menu
local function build_entry_menu(user_id, home_name)
  local home = cfg.homes[home_name]
  local menu = {name=home_name,css={top="75px",header_color="rgba(0,255,125,0.75)"}}

  -- intercom, used to enter in a home
  menu[lang.home.intercom.title()] = {function(player,choice)
    local number = vRP.prompt(player, lang.home.intercom.prompt(), "")
      number = parseInt(number)
      local huser_id = vRP.getUserByAddress(home_name,number)
        if huser_id then
          if huser_id == user_id then -- identify owner (direct home access)
            if not vRP.accessHome(user_id, home_name, number) then
                vRPclient._notify(player,lang.home.intercom.not_available())
              end
          else -- try to access home by asking owner
            local hplayer = vRP.getUserSource(huser_id)
            if hplayer ~= nil then
              local who = vRP.prompt(player,lang.home.intercom.prompt_who(),"")
                vRPclient._notify(player,lang.home.intercom.asked())
                -- request owner to open the door
                if vRP.request(hplayer, lang.home.intercom.request({who}), 30) then
                    vRP.accessHome(user_id, home_name, number)
                  else
                    vRPclient._notify(player,lang.home.intercom.refused())
                  end
            else
              vRPclient._notify(player,lang.home.intercom.refused())
            end
          end
        else
          vRPclient._notify(player,lang.common.not_found())
        end
  end,lang.home.intercom.description()}

  menu[lang.home.buy.title()] = {function(player,choice)
    local address = vRP.getUserAddress(user_id)
      if not address then -- check if not already have a home
        local number = vRP.findFreeNumber(home_name, home.max)
          if number then
            if vRP.tryPayment(user_id, home.buy_price) then
              -- bought, set address
              vRP.setUserAddress(user_id, home_name, number)

              vRPclient._notify(player,lang.home.buy.bought())
            else
              vRPclient._notify(player,lang.money.not_enough())
            end
          else
            vRPclient._notify(player,lang.home.buy.full())
          end
      else
        vRPclient._notify(player,lang.home.buy.have_home())
      end
  end, lang.home.buy.description({home.buy_price})}

  menu[lang.home.sell.title()] = {function(player,choice)
    local address = vRP.getUserAddress(user_id)
      if address and address.home == home_name then -- check if already have a home
        -- sold, give sell price, remove address
        vRP.giveMoney(user_id, home.sell_price)
        vRP.removeUserAddress(user_id)
        vRPclient._notify(player,lang.home.sell.sold())
      else
        vRPclient._notify(player,lang.home.sell.no_home())
      end
  end, lang.home.sell.description({home.sell_price})}

  return menu
end

-- build homes entry points
local function build_client_homes(source)
  local user_id = vRP.getUserId(source)
  if user_id then
    for k,v in pairs(cfg.homes) do
      local x,y,z = table.unpack(v.entry_point)

      local function entry_enter(player,area)
        local user_id = vRP.getUserId(player)
        if user_id and vRP.hasPermissions(user_id,v.permissions or {}) then
          vRP.openMenu(source,build_entry_menu(user_id, k))
        end
      end

      local function entry_leave(player,area)
        vRP.closeMenu(player)
      end

      vRPclient._addBlip(source,x,y,z,v.blipid,v.blipcolor,k)
      vRPclient._addMarker(source,x,y,z-1,0.7,0.7,0.5,0,255,125,125,150)

      vRP.setArea(source,"vRP:home"..k,x,y,z,1,1.5,entry_enter,entry_leave)
    end
  end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then -- first spawn, build homes
    build_client_homes(source)
  else -- death, leave home if inside one
    -- leave slot if inside one
    local tmp = vRP.getUserTmpTable(user_id)
    if tmp and tmp.home_stype then
      leave_slot(user_id, source, tmp.home_stype, tmp.home_sid)
    end
  end
end)

AddEventHandler("vRP:playerLeave",function(user_id, player) 
  -- leave slot if inside one
  local tmp = vRP.getUserTmpTable(user_id)
  if tmp and tmp.home_stype then
    leave_slot(user_id, player, tmp.home_stype, tmp.home_sid)
  end
end)


