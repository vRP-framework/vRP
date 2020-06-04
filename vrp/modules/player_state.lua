-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.player_state then return end

local lang = vRP.lang

local PlayerState = class("PlayerState", vRP.Extension)

-- PRIVATE METHODS

local function define_items(self)
  -- parametric weapon items
  -- give "wbody|WEAPON_PISTOL" and "wammo|WEAPON_PISTOL" to have pistol body and pistol bullets
  -- wbody|weapon
  -- wammo|weapon[|amount] (amount make it an ammo box)

  local function get_wname(weapon_id)
    local name = string.gsub(weapon_id,"WEAPON_","")
    name = string.upper(string.sub(name,1,1))..string.lower(string.sub(name,2))
    -- lang translation support, ex: weapon.pistol = "Pistol", by default use the native name
    return lang.weapon[string.lower(name)]({}, name)
  end

  -- wbody

  local function i_wbody_name(args)
    return lang.item.wbody.name({get_wname(args[2])})
  end

  local function i_wbody_desc(args)
    return lang.item.wbody.description({get_wname(args[2])})
  end

  local function m_wbody_equip(menu)
    local user = menu.user
    local fullid = menu.data.fullid
    local citem = vRP.EXT.Inventory:computeItem(fullid)

    if user:tryTakeItem(fullid, 1) then -- give weapon body
      local weapons = {}
      weapons[citem.args[2]] = {ammo = 0}
      self.remote._giveWeapons(user.source, weapons)

      local namount = user:getItemAmount(fullid)
      if namount > 0 then
        user:actualizeMenu()
      else
        user:closeMenu(menu)
      end
    end
  end

  local function i_wbody_menu(args, menu)
    menu:addOption(lang.item.wbody.equip.title(), m_wbody_equip)
  end

  vRP.EXT.Inventory:defineItem("wbody",i_wbody_name,i_wbody_desc,i_wbody_menu,0.75)

  -- wammo

  local function i_wammo_name(args)
    if args[3] then
      return lang.item.wammo.name_box({get_wname(args[2]), tonumber(args[3]) or 0})
    else
      return lang.item.wammo.name({get_wname(args[2])})
    end
  end

  local function i_wammo_desc(args)
    return lang.item.wammo.description({get_wname(args[2])})
  end

  local function m_wammo_load(menu)
    local user = menu.user
    local fullid = menu.data.fullid

    local amount = user:getItemAmount(fullid)
    local ramount = parseInt(user:prompt(lang.item.wammo.load.prompt({amount}), ""))

    local citem = vRP.EXT.Inventory:computeItem(fullid)

    local weapons = self.remote.getWeapons(user.source)
    if weapons[citem.args[2]] then -- check if the weapon is equiped
      if user:tryTakeItem(fullid, ramount) then -- give weapon ammo
        local weapons = {}
        weapons[citem.args[2]] = {ammo = ramount}
        self.remote._giveWeapons(user.source, weapons)

        local namount = user:getItemAmount(fullid)
        if namount > 0 then
          user:actualizeMenu()
        else
          user:closeMenu(menu)
        end
      end
    end
  end

  local function m_wammo_open(menu)
    local user = menu.user
    local fullid = menu.data.fullid

    local citem = vRP.EXT.Inventory:computeItem(fullid)
    local ammoid = citem.args[1].."|"..citem.args[2]
    local amount = tonumber(citem.args[3]) or 0

    if user:tryTakeItem(fullid, 1, true) and user:tryGiveItem(ammoid, amount, true) then
      user:tryTakeItem(fullid, 1)
      user:tryGiveItem(ammoid, amount)

      local namount = user:getItemAmount(fullid)
      if namount > 0 then
        user:actualizeMenu()
      else
        user:closeMenu(menu)
      end
    end
  end

  local function i_wammo_menu(args, menu)
    if args[3] then
      menu:addOption(lang.item.wammo.open.title(), m_wammo_open)
    else
      menu:addOption(lang.item.wammo.load.title(), m_wammo_load)
    end
  end

  vRP.EXT.Inventory:defineItem("wammo", i_wammo_name,i_wammo_desc,i_wammo_menu,0.01)
end

-- PRIVATE METHODS

-- menu: admin
local function menu_admin(self)
  local function m_model(menu)
    local user = menu.user

    if user:hasPermission("player.custom_model") then
      local model = user:prompt(lang.admin.custom_model.prompt(),"")
      local hash = tonumber(model)
      local custom = {}
      if hash then
        custom.modelhash = hash
      else
        custom.model = model
      end

      self.remote._setCustomization(user.source, custom)
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    local user = menu.user

    if user:hasPermission("player.custom_model") then
      menu:addOption(lang.admin.custom_model.title(), m_model)
    end
  end)
end

-- METHODS

function PlayerState:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/player_state")

  menu_admin(self)

  -- items
  define_items(self)
end

-- EVENT

PlayerState.event = {}

function PlayerState.event:playerSpawn(user, first_spawn)
  if first_spawn then
    self.remote._setConfig(user.source, self.cfg.update_interval, self.cfg.mp_models)
  end
  self.remote._setStateReady(user.source, false)

  -- default customization
  if not user.cdata.state.customization then
    user.cdata.state.customization = self.cfg.default_customization
  end

  -- default position
  if not user.cdata.state.position and self.cfg.spawn_enabled then
    local x = self.cfg.spawn_position[1]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
    local y = self.cfg.spawn_position[2]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
    local z = self.cfg.spawn_position[3]
    user.cdata.state.position = {x=x,y=y,z=z}
  end

  if user.cdata.state.position then -- teleport to saved pos
    vRP.EXT.Base.remote.teleport(user.source,user.cdata.state.position.x,user.cdata.state.position.y,user.cdata.state.position.z, user.cdata.state.heading)
  end

  if user.cdata.state.customization then -- customization
    self.remote.setCustomization(user.source,user.cdata.state.customization) 
  end

  -- weapons
  self.remote.giveWeapons(user.source,user.cdata.state.weapons or {},true)

  if user.cdata.state.health then -- health
    self.remote.setHealth(user.source,user.cdata.state.health)
  end

  if user.cdata.state.armour then -- armour
    self.remote.setArmour(user.source,user.cdata.state.armour)
  end

  self.remote._setStateReady(user.source, true)

  vRP:triggerEvent("playerStateLoaded", user)
end

function PlayerState.event:playerDeath(user)
  user.cdata.state.position = nil
  user.cdata.state.heading = nil
  user.cdata.state.weapons = nil
  user.cdata.state.health = nil
  user.cdata.state.armour = nil
end

function PlayerState.event:characterLoad(user)
  if not user.cdata.state then
    user.cdata.state = {}
  end
end

function PlayerState.event:characterUnload(user)
  self.remote._setStateReady(user.source, false)
end

-- TUNNEL
PlayerState.tunnel = {}

function PlayerState.tunnel:update(state)
  local user = vRP.users_by_source[source]
  if user and user:isReady() then
    for k,v in pairs(state) do
      user.cdata.state[k] = v
    end

    vRP:triggerEvent("playerStateUpdate", user, state)
  end
end

vRP:registerExtension(PlayerState)
