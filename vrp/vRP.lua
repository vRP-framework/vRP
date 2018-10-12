local Luang = module("vrp", "lib/Luang")
local User = module("vrp", "User")

local vRP = class("vRP")

-- STATIC

-- return identification string for the source (used for non vRP identifications, for rejected players)
function vRP.getSourceIdKey(source)
  local ids = GetPlayerIdentifiers(source)
  local idk = "idk_"
  for k,v in pairs(ids) do
    idk = idk..v
  end

  return idk
end

function vRP.getPlayerEndpoint(player)
  return GetPlayerEP(player) or "0.0.0.0"
end

function vRP.getPlayerName(player)
  return GetPlayerName(player) or "unknown"
end

-- METHODS

function vRP:__construct()
  -- load config
  self.cfg = module("vrp", "cfg/base")

  -- load language 
  self.luang = Luang()
  self.luang:loadLocale(self.cfg.lang, module("cfg/lang/"..self.cfg.lang) or {})
  self.lang = self.luang.lang[self.cfg.lang]

  self.users = {} -- will store logged users (id) by first identifier
  self.rusers = {} -- store the opposite of users
  self.user_tables = {} -- user data tables (logger storage, saved to database)
  self.user_tmp_tables = {} -- user tmp data tables (logger storage, not saved)
  self.user_sources = {} -- user sources 

  -- db/SQL API
  self.db_drivers = {}
  self.db_driver = nil
  self.cached_prepares = {}
  self.cached_queries = {}
  self.prepared_queries = {}
  self.db_initialized = false

  -- DB driver error/warning

  if not self.cfg.db or not self.cfg.db.driver then
    error("[vRP] Missing DB config driver.")
  end

  -- DB driver check thread
  Citizen.CreateThread(function()
    while not self.db_initialized do
      print("[vRP] DB driver \""..self.cfg.db.driver.."\" not initialized yet ("..#self.cached_prepares.." prepares cached, "..#self.cached_queries.." queries cached).")
      Citizen.Wait(5000)
    end
  end)
end

-- register a DB driver
--- name: unique name for the driver
--- on_init(cfg): called when the driver is initialized (connection), should return true on success
---- cfg: db config
--- on_prepare(name, query): should prepare the query (@param notation)
--- on_query(name, params, mode): should execute the prepared query
---- params: map of parameters
---- mode: 
----- "query": should return rows, affected
----- "execute": should return affected
----- "scalar": should return a scalar
function vRP:registerDBDriver(name, on_init, on_prepare, on_query)
  if not self.db_drivers[name] then
    self.db_drivers[name] = {on_init, on_prepare, on_query}

    if name == self.cfg.db.driver then -- use/init driver
      self.db_driver = self.db_drivers[name] -- set driver

      local ok = on_init(self.cfg.db)
      if ok then
        print("[vRP] Connected to DB using driver \""..name.."\".")
        self.db_initialized = true
        -- execute cached prepares
        for _,prepare in pairs(self.cached_prepares) do
          on_prepare(table.unpack(prepare, 1, table.maxn(prepare)))
        end

        -- execute cached queries
        for _,query in pairs(self.cached_queries) do
          async(function()
            query[2](on_query(table.unpack(query[1], 1, table.maxn(query[1]))))
          end)
        end

        self.cached_prepares = nil
        self.cached_queries = nil
      else
        error("[vRP] Connection to DB failed using driver \""..name.."\".")
      end
    end
  else
    error("[vRP] DB driver \""..name.."\" already registered.")
  end
end

-- prepare a query
--- name: unique name for the query
--- query: SQL string with @params notation
function vRP:prepare(name, query)
  if Debug.active then
    Debug.log("prepare "..name.." = \""..query.."\"")
  end

  self.prepared_queries[name] = true

  if self.db_initialized then -- direct call
    self.db_driver[2](name, query)
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
  if not self.prepared_queries[name] then
    error("[vRP] query "..name.." doesn't exist.")
  end

  if not mode then mode = "query" end

  if Debug.active then
    Debug.log("query "..name.." ("..mode..") params = "..json.encode(params or {}))
  end

  if self.db_initialized then -- direct call
    return self.db_driver[3](name, params or {}, mode)
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

-- identification system

-- return user id or nil in case of error (if not found, will create it)
function vRP:getUserIdByIdentifiers(ids)
  if ids and #ids then
    -- search identifiers
    for i=1,#ids do
      if not self.cfg.ignore_ip_identifier or (string.find(ids[i], "ip:") == nil) then  -- ignore ip identifier
        local rows = self:query("vRP/userid_byidentifier", {identifier = ids[i]})
        if #rows > 0 then  -- found
          return rows[1].user_id
        end
      end
    end

    -- no ids found, create user
    local rows, affected = self:query("vRP/create_user", {})

    if #rows > 0 then
      local user_id = rows[1].id
      -- add identifiers
      for l,w in pairs(ids) do
        if not self.cfg.ignore_ip_identifier or (string.find(w, "ip:") == nil) then  -- ignore ip identifier
          self:execute("vRP/add_identifier", {user_id = user_id, identifier = w})
        end
      end

      return user_id
    end
  end
end

function vRP:isBanned(user_id)
  local rows = self:query("vRP/get_banned", {user_id = user_id})
  if #rows > 0 then
    return rows[1].banned
  else
    return false
  end
end

function vRP:setBanned(user_id,banned)
  self:execute("vRP/set_banned", {user_id = user_id, banned = banned})
end

function vRP:isWhitelisted(user_id)
  local rows = self:query("vRP/get_whitelisted", {user_id = user_id})
  if #rows > 0 then
    return rows[1].whitelisted
  else
    return false
  end
end

function vRP:setWhitelisted(user_id,whitelisted)
  vRP:execute("vRP/set_whitelisted", {user_id = user_id, whitelisted = whitelisted})
end

function vRP:getLastLogin(user_id)
  local rows = self:query("vRP/get_last_login", {user_id = user_id})
  if #rows > 0 then
    return rows[1].last_login
  else
    return ""
  end
end

function vRP:setUData(user_id,key,value)
  self:execute("vRP/set_userdata", {user_id = user_id, key = key, value = value})
end

function vRP:getUData(user_id,key)
  local rows = self:query("vRP/get_userdata", {user_id = user_id, key = key})
  if #rows > 0 then
    return rows[1].dvalue
  else
    return ""
  end
end

function vRP:setCData(character_id,key,value)
  self:execute("vRP/set_characterdata", {character_id = character_id, key = key, value = value})
end

function vRP:getCData(character_id,key)
  local rows = self:query("vRP/get_characterdata", {character_id = character_id, key = key})
  if #rows > 0 then
    return rows[1].dvalue
  else
    return ""
  end
end

function vRP:setSData(key,value,id)
  if not id then id = config.server_id end

  self:execute("vRP/set_srvdata", {key = key, value = value, id = id})
end

function vRP:getSData(key,id)
  if not id then id = self.cfg.server_id end

  local rows = self:query("vRP/get_srvdata", {key = key, id = id})
  if #rows > 0 then
    return rows[1].dvalue
  else
    return ""
  end
end

return vRP
