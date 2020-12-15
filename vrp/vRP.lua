-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

local Luang = module("vrp", "lib/Luang")
local vRPShared = module("vrp", "vRPShared")

-- Server vRP
local vRP = class("vRP", vRPShared)

-- SUBCLASSES

vRP.DBDriver = class("vRP.DBDriver")

-- called when the driver is initialized (connection), should return true on success
-- db_cfg: cfg/base.lua .db config
function vRP.DBDriver:onInit(db_cfg)
  return false
end

-- should prepare the query (@param notation)
function vRP.DBDriver:onPrepare(name, query)
end

-- should execute the prepared query
-- params: map of parameters
-- mode: 
--- "query": should return rows, affected
--- "execute": should return affected
--- "scalar": should return a scalar
function vRP.DBDriver:onQuery(name, params, mode)
  if mode == "query" then
    return {}, 0
  elseif mode == "execute" then
    return 0
  elseif mode == "scalar" then
    return 0
  end
end

-- STATIC

function vRP.getPlayerEndpoint(player)
  return GetPlayerEP(player) or "0.0.0.0"
end

function vRP.getPlayerName(player)
  return GetPlayerName(player) or "unknown"
end

-- METHODS

function vRP:__construct()
  vRPShared.__construct(self)

  -- load config
  self.cfg = module("vrp", "cfg/base")
  self.log_level = self.cfg.log_level

  -- load language 
  self.luang = Luang()
  self.luang:loadLocale(self.cfg.lang, module("cfg/lang/"..self.cfg.lang) or {})
  self.lang = self.luang.lang[self.cfg.lang]

  self.users = {} -- map of id => User
  self.users_by_source = {} -- map of source => user
  self.users_by_cid = {} -- map of character id => user

  -- db/SQL API
  self.db_drivers = {}
  self.db_driver = nil
  self.cached_prepares = {}
  self.cached_queries = {}
  self.prepared_queries = {}
  self.db_initialized = false

  -- DB driver error/warning

  if not self.cfg.db or not self.cfg.db.driver then
    self:error("Missing DB config driver.")
  end

  -- DB driver check thread
  Citizen.CreateThread(function()
    while not self.db_initialized do
      self:log("DB driver \""..self.cfg.db.driver.."\" not initialized yet ("..#self.cached_prepares.." prepares cached, "..#self.cached_queries.." queries cached).")
      Citizen.Wait(5000)
    end
  end)

  -- other tasks
  local function task_save()
    SetTimeout(self.cfg.save_interval*1000, task_save)
    self:save()
  end
  task_save()
end

-- register a DB driver
-- db_driver: DBDriver class
function vRP:registerDBDriver(db_driver)
  if class.is(db_driver, vRP.DBDriver) then
    local name = class.name(db_driver)
    if not self.db_drivers[name] then
      self.db_drivers[name] = db_driver

      if name == self.cfg.db.driver then -- use/init driver
        self.db_driver = self.db_drivers[name]() -- init driver

        local ok = self.db_driver:onInit(self.cfg.db)
        if ok then
          self:log("Connected to DB using driver \""..name.."\".")
          self.db_initialized = true
          -- execute cached prepares
          for _, prepare in pairs(self.cached_prepares) do
            self.db_driver:onPrepare(table.unpack(prepare))
          end
          -- execute cached queries
          for _, query in pairs(self.cached_queries) do
            query[2](self.db_driver:onQuery(table.unpack(query[1])))
          end
          self.cached_prepares = nil
          self.cached_queries = nil
        else
          self:error("Connection to DB failed using driver \""..name.."\".")
        end
      end
    else
      self:error("DB driver \""..name.."\" already registered.")
    end
  else
    self:error("Not a DBDriver class.")
  end
end

-- prepare a query
--- name: unique name for the query
--- query: SQL string with @params notation
function vRP:prepare(name, query)
  if self.log_level > 0 then
    self:log("prepare "..name.." = \""..query.."\"")
  end

  self.prepared_queries[name] = true

  if self.db_initialized then -- direct call
    self.db_driver:onPrepare(name, query)
  else
    table.insert(self.cached_prepares, {name, query})
  end
end

-- execute a query
--- name: unique name of the query
--- params: map of parameters
--- mode: default is "query"
---- "query": should return rows (list of map of parameter => value), affected
---- "execute": should return affected
---- "scalar": should return a scalar
function vRP:query(name, params, mode)
  if not mode then mode = "query" end

  if not self.prepared_queries[name] then
    self:error("query "..name.." doesn't exist.")
  end
  if self.log_level > 0 then
    self:log("query "..name.." ("..mode..") params = "..json.encode(params or {}))
  end
  if self.db_initialized then -- direct call
    return self.db_driver:onQuery(name, params or {}, mode)
  else -- async call, wait query result
    local r = async()
    table.insert(self.cached_queries, {{name, params or {}, mode}, r})
    return r:wait()
  end
end

-- shortcut for vRP.query with "execute"
function vRP:execute(name, params)
  return self:query(name, params, "execute")
end

-- shortcut for vRP.query with "scalar"
function vRP:scalar(name, params)
  return self:query(name, params, "scalar")
end

-- Identification system.

-- Authenticate a user by source (async).
-- Will create the user based on source data.
--
-- return user id or nil on failure
function vRP:authUser(source)
  local raw_ids = GetPlayerIdentifiers(source)
  local ids = {}
  -- filter identifiers
  if raw_ids then
    for _, id in ipairs(raw_ids) do
      if not self.cfg.ignore_ip_identifier or not string.find(id, "^ip:") then
        table.insert(ids, id)
      end
    end
  end
  if #ids == 0 then return end
  -- search identifiers
  for _, id in ipairs(ids) do
    local rows = self:query("vRP/userid_byidentifier", {identifier = id})
    if #rows > 0 then return rows[1].user_id end
  end
  -- no ids found, create user
  local rows, affected = self:query("vRP/create_user", {})
  if #rows > 0 then
    local user_id = rows[1].id
    -- add identifiers
    for _, id in pairs(ids) do
      self:execute("vRP/add_identifier", {user_id = user_id, identifier = id})
    end
    return user_id
  end
end

-- (async)
-- return user or nil on failure
function vRP:connectUser(source)
  local user = self.users_by_source[source]
  if user then return user end -- already connected
  -- load user
  --- auth
  local user_id = self:authUser(source)
  if not user_id then return end
  --- check/disconnect already connected user
  local prev_user = self.users[user_id]
  if prev_user then self:disconnectUser(prev_user.source) end
  --- User class deferred loading
  if not self.User then self.User = module("vrp", "User") end
  --- init user
  user = self.User(source, user_id)
  self.users[user_id] = user
  self.users_by_source[source] = user
  user.name = vRP.getPlayerName(source)
  user.endpoint = vRP.getPlayerEndpoint(source)
  user.spawns = 0
  --- data
  local sdata = self:getUData(user_id, "vRP:datatable")
  if string.len(sdata) > 0 then
    local data = msgpack.unpack(sdata)
    if type(data) == "table" then user.data = data end
  end
  --- character
  if not user:useCharacter(user.data.current_character or 0) then -- use last used character
    local characters = user:getCharacters()
    if #characters > 0 then -- use existing character
      user:useCharacter(characters[1])
    else -- use new character
      local cid = user:createCharacter()
      if cid then
        user:useCharacter(cid)
      else
        self:error("couldn't create character (user_id = "..user_id..")")
      end
    end
  end
  --- last login
  user.last_login = user.data.last_login or ""
  user.data.last_login = os.date("%H:%M:%S %d/%m/%Y")
  -- trigger join
  self:log(user.name.." ("..user.endpoint..") connected (user_id = "..user.id..")")
  self:triggerEvent("playerJoin", user)
  return user
end

function vRP:disconnectUser(source)
  local user = self.users_by_source[source]
  if user then
    -- remove player from connected clients
    self.EXT.Base.remote._removePlayer(-1, user.source)
    self:triggerEventSync("characterUnload", user)
    self:triggerEventSync("playerLeave", user)
    -- save user
    user:save()
    -- unreference
    self.users[user.id] = nil
    self.users_by_source[user.source] = nil
    self:log(user.name.." ("..user.endpoint..") disconnected (user_id = "..user.id..")")
  end
end

-- user data
-- value: binary string
function vRP:setUData(user_id, key, value)
  self:execute("vRP/set_userdata", {user_id = user_id, key = key, value = tohex(value)})
end

function vRP:getUData(user_id, key)
  local rows = self:query("vRP/get_userdata", {user_id = user_id, key = key})
  return #rows > 0 and rows[1].dvalue or ""
end

-- character data
-- value: binary string
function vRP:setCData(character_id, key, value)
  self:execute("vRP/set_characterdata", {character_id = character_id, key = key, value = tohex(value)})
end

function vRP:getCData(character_id, key)
  local rows = self:query("vRP/get_characterdata", {character_id = character_id, key = key})
  return #rows > 0 and rows[1].dvalue or ""
end

-- server data
-- value: binary string
function vRP:setSData(key, value, id)
  if not id then id = self.cfg.server_id end
  self:execute("vRP/set_serverdata", {key = key, value = tohex(value), id = id})
end

function vRP:getSData(key, id)
  if not id then id = self.cfg.server_id end
  local rows = self:query("vRP/get_serverdata", {key = key, id = id})
  return #rows > 0 and rows[1].dvalue or ""
end

-- global data
-- value: binary string
function vRP:setGData(key, value)
  self:execute("vRP/set_globaldata", {key = key, value = tohex(value)})
end

function vRP:getGData(key)
  local rows = self:query("vRP/get_globaldata", {key = key})
  return #rows > 0 and rows[1].dvalue or ""
end

-- reason: (optional)
function vRP:kick(user, reason)
  DropPlayer(user.source, reason or "")
end

function vRP:save()
  if self.log_level > 0 then self:log("save users") end
  self:triggerEvent("save")
  for user_id, user in pairs(self.users) do user:save() end
end

-- events

function vRP:onPlayerSpawned(source)
  local user = self.users_by_source[source]
  if not user then user = self:connectUser(source) end
  if user then
    user.spawns = user.spawns+1
    local first_spawn = (user.spawns == 1)
    if first_spawn then
      -- first spawn, reference player
      -- send players to new player
      for id, user in pairs(self.users) do
        self.EXT.Base.remote._addPlayer(source, user.source)
      end
      -- send new player to all players
      self.EXT.Base.remote._addPlayer(-1 ,user.source)
      -- set client tunnel delay at first spawn
      Tunnel.setDestDelay(user.source, self.cfg.load_delay)
      self:triggerEvent("playerDelay", user, true)
      SetTimeout(2000, function() 
        SetTimeout(self.cfg.load_duration*1000, function() -- set client delay to normal delay
          Tunnel.setDestDelay(user.source, self.cfg.global_delay)
          self:triggerEvent("playerDelay", user, false)
        end)
      end)
    end
    SetTimeout(2000, function() -- trigger spawn event
      self:triggerEvent("playerSpawn", user, first_spawn)
    end)
  end
end

function vRP:onPlayerDropped(source)
  self:disconnectUser(source)
end

function vRP:onPlayerDied(source)
  local user = self.users_by_source[source]
  if user then self:triggerEvent("playerDeath", user) end
end

return vRP
