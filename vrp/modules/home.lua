-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.home then return end

local lang = vRP.lang
local htmlEntities = module("vrp", "lib/htmlEntities")

-- this module describe the home system 

-- Component
local Component = class("Home.Component")

function Component:__construct(slot, id, index, cfg, x, y, z)
  self.slot = slot
  self.id = id
  self.index = index
  self.cfg = cfg
  self.x = x
  self.y = y
  self.z = z
end

-- called when the component is loaded for a specific slot
function Component:load()
end

-- called when the component is unloaded from a specific slot
function Component:unload()
end

-- called when a player enters the slot
function Component:enter(user)
end

-- called when a player leaves the slot
function Component:leave(user)
end

-- Slot
local Slot = class("Slot")

function Slot:__construct(type, id, owner_id, home, number)
  self.type = type
  self.id = id
  self.owner_id = owner_id -- character id
  self.home = home
  self.number = number

  self.users = {} -- map of users
  self.components = {} -- map of index => component
end

function Slot:isEmpty()
  return not next(self.users)
end

function Slot:load()
  -- load components
  for i,cfg in pairs(vRP.EXT.Home.cfg.slot_types[self.type][self.id]) do
    local id,x,y,z = table.unpack(cfg)

    -- get component class
    local ccomponent = vRP.EXT.Home.components[id]
    if ccomponent then
      -- instantiate component
      local component = ccomponent(self, id, i, cfg._config or {}, x,y,z)
      self.components[i] = component

      component:load()
    else
      vRP.EXT.Home:log("WARNING: try to instantiate undefined component \""..id.."\"")
    end
  end
end

function Slot:unload()
  -- unload components
  for i,component in pairs(self.components) do
    component:unload()
    self.components[i] = nil
  end
end

function Slot:enter(user)
  self.users[user] = true

  -- components enter
  for i,component in pairs(self.components) do
    component:enter(user)
  end
end

function Slot:leave(user)
  -- components leave
  for i,component in pairs(self.components) do
    component:leave(user)
  end

  -- teleport to home entry point (outside)
  local home_cfg = vRP.EXT.Home.cfg.homes[self.home]
  vRP.EXT.Base.remote._teleport(user.source, table.unpack(home_cfg.entry_point)) -- already an array of params (x,y,z)

  self.users[user] = nil
end

-- Entry component

local EntryComponent = class("entry", Component)

function EntryComponent:load()
  self.point_id = "vRP:home:component:entry:"..self.index
end

function EntryComponent:enter(user)
  local x,y,z = self.x, self.y, self.z
  -- teleport to the slot entry point
  vRP.EXT.Base.remote._teleport(user.source, self.x,self.y,self.z)

  -- build entry

  local menu
  local function enter(user)
    menu = user:openMenu("home:component:entry", {slot = self.slot})
  end

  local function leave(user)
    if menu then
      user:closeMenu(menu)
    end
  end

  local ment = clone(vRP.EXT.Home.cfg.entry_map_entity)
  ment[2].pos = {x,y,z-1}
  vRP.EXT.Map.remote._setEntity(user.source,self.point_id,ment[1],ment[2])

  user:setArea(self.point_id,x,y,z,1,1.5,enter,leave)
end

function EntryComponent:leave(user)
  vRP.EXT.Map.remote._removeEntity(user.source, self.point_id)
  user:removeArea(self.point_id)
end

-- Extension

local Home = class("Home", vRP.Extension)

-- SUBCLASS

-- Component

Home.Component = Component

-- User

Home.User = class("User")

-- access a home by address
-- return true on success
function Home.User:accessHome(home, number)
  self:leaveHome()

  local slot = vRP.EXT.Home:getSlotByAddress(home,number) -- get already loaded slot

  if not slot then -- load slot
    local home_cfg = vRP.EXT.Home.cfg.homes[home]

    if home_cfg then
      -- find free slot
      local sid = vRP.EXT.Home:findFreeSlot(home_cfg.slot)
      if sid then
        local owner_id = vRP.EXT.Home:getByAddress(home,number)
        if owner_id then
          -- allocate slot
          slot = Slot(home_cfg.slot, sid, owner_id, home, number)
          vRP.EXT.Home.slots[home_cfg.slot][sid] = slot
          slot:load()
        end
      end
    end
  end

  if slot then 
    slot:enter(self)
    self.home_slot = slot
    return true
  end
end

function Home.User:leaveHome()
  if self.home_slot then
    self.home_slot:leave(self)

    if self.home_slot:isEmpty() then -- free slot
      self.home_slot:unload()
      vRP.EXT.Home.slots[self.home_slot.type][self.home_slot.id] = nil
    end

    self.home_slot = nil
  end
end

-- check if inside a home
function Home.User:inHome()
  return self.home_slot ~= nil
end

-- PRIVATE METHODS

-- menu: home component entry
local function menu_home_component_entry(self)
  local function m_leave(menu)
    menu.user:leaveHome()
  end

  local function m_ejectall(menu)
    local slot = menu.data.slot

    for user in pairs(slot.users) do
      user:leaveHome()
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("home:component:entry", function(menu)
    local user = menu.user
    local slot = menu.data.slot

    menu.title = slot.home
    menu.css.header_color = "rgba(0,255,125,0.75)"

    menu:addOption(lang.home.slot.leave.title(), m_leave)

    -- if owner
    if slot.owner_id == user.cid then
      menu:addOption(lang.home.slot.ejectall.title(), m_ejectall, lang.home.slot.ejectall.description())
    end
  end)
end

-- menu: home
local function menu_home(self)
  local function m_intercom(menu)
    local user = menu.user

    local number = parseInt(user:prompt(lang.home.intercom.prompt(), ""))
    local huser
    local hcid = self:getByAddress(menu.data.name,number)
    if hcid then huser = vRP.users_by_cid[hcid] end
    if huser then
      if huser == user then -- identify owner (direct home access)
        if not user:accessHome(menu.data.name, number) then
          vRP.EXT.Base.remote._notify(user.source,lang.home.intercom.not_available())
        end
      else -- try to access home by asking owner
        local who = user:prompt(lang.home.intercom.prompt_who(),"")
        vRP.EXT.Base.remote._notify(user.source,lang.home.intercom.asked())
        -- request owner to open the door
        if huser:request(lang.home.intercom.request({who}), 30) then
          user:accessHome(menu.data.name, number)
        else
          vRP.EXT.Base.remote._notify(user.source,lang.home.intercom.refused())
        end
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.not_found())
    end
  end

  local function m_buy(menu)
    local user = menu.user
    local home_cfg = self.cfg.homes[menu.data.name]

    if not user.address then -- check if not already have a home
      local number = self:findFreeNumber(menu.data.name, home_cfg.max)
      if user.address then return end -- after coroutine check (prevent double buy)

      if number then
        if user:tryPayment(home_cfg.buy_price) then
          -- bought, set address
          user.address = {character_id = user.cid, home = menu.data.name, number = number}
          vRP:execute("vRP/set_address", {character_id = user.cid, home = menu.data.name, number = number})
          vRP:triggerEvent("characterAddressUpdate", user)

          vRP.EXT.Base.remote._notify(user.source,lang.home.buy.bought())
        else
          vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.home.buy.full())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.home.buy.have_home())
    end
  end

  local function m_sell(menu)
    local user = menu.user
    local home_cfg = self.cfg.homes[menu.data.name]

    local address = user.address
    if address and address.home == menu.data.name then -- check have home
      -- sold, give sell price, remove address
      user.address = nil
      user:giveWallet(home_cfg.sell_price)
      vRP:execute("vRP/rm_address", {character_id = user.cid})

      vRP:triggerEvent("characterAddressUpdate", user)

      vRP.EXT.Base.remote._notify(user.source,lang.home.sell.sold())
    else
      vRP.EXT.Base.remote._notify(user.source,lang.home.sell.no_home())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("home", function(menu)
    menu.title = menu.data.name
    menu.css.header_color = "rgba(0,255,125,0.75)"

    local home_cfg = self.cfg.homes[menu.data.name]

    menu:addOption(lang.home.intercom.title(), m_intercom, lang.home.intercom.description())
    menu:addOption(lang.home.buy.title(), m_buy, lang.home.buy.description({home_cfg.buy_price}))
    menu:addOption(lang.home.sell.title(), m_sell, lang.home.sell.description({home_cfg.sell_price}))
  end)
end

-- METHODS

function Home:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/homes") 

  self.components = {}
  self.slots = {} -- map of type => map of slot id => slot instance

  -- init slot types
  for stype in pairs(self.cfg.slot_types) do
    self.slots[stype] = {}
  end

  async(function()
    -- sql
    vRP:prepare("vRP/home_tables", [[
    CREATE TABLE IF NOT EXISTS vrp_character_homes(
      character_id INTEGER,
      home VARCHAR(100),
      number INTEGER,
      CONSTRAINT pk_character_homes PRIMARY KEY(character_id),
      CONSTRAINT fk_character_homes_characters FOREIGN KEY(character_id) REFERENCES vrp_characters(id) ON DELETE CASCADE,
      UNIQUE(home,number)
    );
    ]])

    vRP:prepare("vRP/get_address","SELECT home, number FROM vrp_character_homes WHERE character_id = @character_id")
    vRP:prepare("vRP/get_home_owner","SELECT character_id FROM vrp_character_homes WHERE home = @home AND number = @number")
    vRP:prepare("vRP/rm_address","DELETE FROM vrp_character_homes WHERE character_id = @character_id")
    vRP:prepare("vRP/set_address","REPLACE INTO vrp_character_homes(character_id,home,number) VALUES(@character_id,@home,@number)")

    -- init
    vRP:execute("vRP/home_tables")
  end)

  -- menu
  menu_home_component_entry(self)
  menu_home(self)

  -- permissions

  vRP.EXT.Group:registerPermissionFunction("home", function(user, params)
    local address = user.address

    local ok = (address ~= nil)

    if ok and params[2] then
      ok = (params[2] == string.gsub(address.home, "%.", ""))
    end

    if ok and params[3] then
      ok = (tonumber(params[3]) == address.number)
    end

    return ok
  end)

  -- identity info
  vRP.EXT.GUI:registerMenuBuilder("identity", function(menu)
    local address = self:getAddress(menu.data.cid)

    if address then
      menu:addOption(lang.home.address.title(), nil, lang.home.address.info({address.number, htmlEntities.encode(address.home)}))
    end
  end)

  -- entry component
  self:registerComponent(EntryComponent)
end

-- address access (online and offline characters)
-- return address or nil
function Home:getAddress(cid)
  local user = vRP.users_by_cid[cid]
  if user then
    return user.address
  else
    local rows = vRP:query("vRP/get_address", {character_id = cid})
    return rows[1]
  end
end

-- return character id or nil
function Home:getByAddress(home,number)
  local rows = vRP:query("vRP/get_home_owner", {home = home, number = number})
  if #rows > 0 then
    return rows[1].character_id
  end
end

-- find a free address number to buy
-- return number or nil if no numbers availables
function Home:findFreeNumber(home,max)
  local i = 1
  while i <= max do
    if not self:getByAddress(home,i) then
      return i
    end
    i = i+1
  end
end

-- register home component
-- id: unique component identifier (string)
-- component: Home.Component derived class
function Home:registerComponent(component)
  if class.is(component, Home.Component) then
    local id = class.name(component)
    if self.components[id] then
      self:log("WARNING: re-registered component \""..id.."\"")
    end

    self.components[id] = component
  else
    self:error("Not a Component class.")
  end
end

-- SLOTS

-- get slot instance
-- return slot or nil
function Home:getSlot(stype, sid)
  local group = self.slots[stype]
  if group then
    return group[sid]
  end
end

-- get slot instance by address
-- return slot or nil
function Home:getSlotByAddress(home, number)
  for stype,slots in pairs(self.slots) do
    for sid,slot in pairs(slots) do
      if slot.home == home and slot.number == number then
        return slot
      end
    end
  end
end

-- return sid or nil
function Home:findFreeSlot(stype)
  local group = self.slots[stype]
  local group_cfg = self.cfg.slot_types[stype]
  if group_cfg then
    for sid in ipairs(group_cfg) do
      if not group[sid] then
        return sid
      end
    end
  end
end

-- EVENT
Home.event = {}

function Home.event:characterLoad(user)
  -- load address
  local rows = vRP:query("vRP/get_address", {character_id = user.cid})
  user.address = rows[1]

  vRP:triggerEvent("characterAddressUpdate", user)
end

function Home.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- build home entries
    for name,cfg in pairs(self.cfg.homes) do
      local x,y,z = table.unpack(cfg.entry_point)

      local menu
      local function enter(user)
        if user:hasPermissions(cfg.permissions or {}) then
          menu = user:openMenu("home", {name = name})
        end
      end

      local function leave(user)
        if menu then
          user:closeMenu(menu)
        end
      end

      local ment = clone(cfg.map_entity)
      ment[2].title = name
      ment[2].pos = {x,y,z-1}
      vRP.EXT.Map.remote._addEntity(user.source,ment[1],ment[2])

      user:setArea("vRP:home:"..name,x,y,z,1,1.5,enter,leave)
    end
  end
end

function Home.event:playerStateUpdate(user, state)
  -- override player state position when in home (to home entry)
  if state.position then
    local slot = user.home_slot
    if slot then
      local home_cfg = self.cfg.homes[slot.home]
      if home_cfg then
        local x,y,z = table.unpack(home_cfg.entry_point)
        user.cdata.state.position = {x=x,y=y,z=z}
      end
    end
  end
end

function Home.event:characterUnload(user)
  user:leaveHome()
end

function Home.event:playerLeave(user)
  user:leaveHome()
end

function Home.event:playerDeath(user)
  user:leaveHome()
end

vRP:registerExtension(Home)
