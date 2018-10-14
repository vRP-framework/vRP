local Luang = module("vrp", "lib/Luang")
local User
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

-- return identification string for a specific source
function vRP.getSourceIdKey(source)
  return table.concat(GetPlayerIdentifiers(source) or {}, ";")
end

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

  -- load language 
  self.luang = Luang()
  self.luang:loadLocale(self.cfg.lang, module("cfg/lang/"..self.cfg.lang) or {})
  self.lang = self.luang.lang[self.cfg.lang]

  self.users = {} -- map of id => User
  self.pending_users = {} -- pending user source update (first spawn), map of ids key => user
  self.users_by_source = {} -- map of source => User

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

  -- other tasks
  local function task_save()
    SetTimeout(self.cfg.save_interval*1000, task_save)
    self:save()
  end
  task_save()

  local function task_timeout()
    SetTimeout(30000, task_timeout)
    self:checkTimeout()
  end
  task_timeout()
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
          print("[vRP] Connected to DB using driver \""..name.."\".")
          self.db_initialized = true
          -- execute cached prepares
          for _,prepare in pairs(self.cached_prepares) do
            self.db_driver:onPrepare(table.unpack(prepare, 1, table.maxn(prepare)))
          end

          -- execute cached queries
          for _,query in pairs(self.cached_queries) do
            async(function()
              query[2](self.db_driver:onQuery(table.unpack(query[1], 1, table.maxn(query[1]))))
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
  else
    error("[vRP] Not a DBDriver class.")
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
  if not self.prepared_queries[name] then
    error("[vRP] query "..name.." doesn't exist.")
  end

  if not mode then mode = "query" end

  if Debug.active then
    Debug.log("query "..name.." ("..mode..") params = "..json.encode(params or {}))
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
  self:execute("vRP/set_whitelisted", {user_id = user_id, whitelisted = whitelisted})
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

  self:execute("vRP/set_serverdata", {key = key, value = value, id = id})
end

function vRP:getSData(key,id)
  if not id then id = self.cfg.server_id end

  local rows = self:query("vRP/get_serverdata", {key = key, id = id})
  if #rows > 0 then
    return rows[1].dvalue
  else
    return ""
  end
end

-- drop vRP player/user (internal usage)
function vRP:dropPlayer(source)
  local ids_key = vRP.getSourceIdKey(source)
  local user = self.users_by_source[source]
  local pending = false
  if not user then -- pending user check
    user = self.pending_users[ids_key]
    pending = true
  end

  if user then
    -- remove player from connected clients
    self.EXT.Base.remote._removePlayer(-1, user.source)

    self:triggerEvent("playerLeave", user)

    -- save user data table
    self:setUData(user.id,"vRP:datatable",json.encode(user.data))

    print("[vRP] "..user.endpoint.." disconnected (user_id = "..user.id..")")
    vRP.users[user.id] = nil
    vRP.user_sources[user.source] = nil

    if pending then
      vRP.pending_users[ids_key] = nil
    end
  end
end

function vRP:ban(user,reason)
  self:setBanned(user.id,true)
  self:kick(user.source, "[Banned] "..reason)
end

function vRP:kick(source,reason)
  DropPlayer(source,reason)
end

function vRP:save()
  self:triggerEvent("save")

  Debug.log("save datatables")
  for k,user in pairs(self.users) do
    self:setUData(user.id,"vRP:datatable",json.encode(user.data))
  end
end

function vRP:checkTimeout()
  for k,user in pairs(self.users) do
    if GetPlayerPing(user.source) <= 0 then
      self:kick(user.source,"[vRP] Ping timeout.")
      self:dropPlayer(user.source)
    end
  end
end

-- events

function vRP:onPlayerConnecting(source, name, setMessage, deferrals)
  deferrals.defer()

  Debug.log("playerConnecting "..name)
  local ids = GetPlayerIdentifiers(source)

  if ids ~= nil and #ids > 0 then
    deferrals.update("[vRP] Checking identifiers...")

    local user_id = self:getUserIdByIdentifiers(ids)
    -- if user_id ~= nil and vRP.rusers[user_id] == nil then -- check user validity and if not already connected (old way, disabled until playerDropped is sure to be called)
    if user_id then -- check user validity 
      deferrals.update("[vRP] Checking banned...")
      if not self:isBanned(user_id) then
        deferrals.update("[vRP] Checking whitelisted...")
        if not self.cfg.whitelist or self:isWhitelisted(user_id) then
          if not self.users[user_id] then -- not present on the server, init user
            -- load user data table
            deferrals.update("[vRP] Loading datatable...")
            local sdata = self:getUData(user_id, "vRP:datatable")

            -- User class deferred loading
            if not User then User = module("vrp", "User") end

            local user = User(source, user_id)
            self.users[user_id] = user
            self.users_by_source[source] = user
            self.pending_users[table.concat(ids, ";")] = user

            local data = json.decode(sdata)
            if type(data) == "table" then user.data = data end

            deferrals.update("[vRP] Getting last login...")
            user.last_login = self:getLastLogin(user.id) or ""
            user.spawns = 0
            user.name = name

            -- set endpoint
            local ep = vRP.getPlayerEndpoint(source)
            user.endpoint = ep

            -- set last login
            local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
            self:execute("vRP/set_last_login", {user_id = user.id, last_login = last_login_stamp})

            -- trigger join
            print("[vRP] "..user.name.." ("..user.endpoint..") joined (user_id = "..user.id..")")
            self:triggerEvent("playerJoin", user)
            deferrals.done()
          else -- already connected
            print("[vRP] "..user.name.." ("..user.endpoint..") re-joined (user_id = "..user.id..")")
            -- reset first spawn
            user.spawns = 0

            self:triggerEvent("playerRejoin", user, name)
            deferrals.done()
          end

        else
          print("[vRP] "..name.." ("..vRP.getPlayerEndpoint(source)..") rejected: not whitelisted (user_id = "..user_id..")")
          Citizen.Wait(1000)
          deferrals.done("[vRP] Not whitelisted (user_id = "..user_id..").")
        end
      else
        print("[vRP] "..name.." ("..vRP.getPlayerEndpoint(source)..") rejected: banned (user_id = "..user_id..")")
        Citizen.Wait(1000)
        deferrals.done("[vRP] Banned (user_id = "..user_id..").")
      end
    else
      print("[vRP] "..name.." ("..vRP.getPlayerEndpoint(source)..") rejected: identification error")
      Citizen.Wait(1000)
      deferrals.done("[vRP] Identification error.")
    end
  else
    print("[vRP] "..name.." ("..vRP.getPlayerEndpoint(source)..") rejected: missing identifiers")
    Citizen.Wait(1000)
    deferrals.done("[vRP] Missing identifiers.")
  end
end

function vRP:onPlayerSpawned(source)
  Debug.log("playerSpawned "..source)

  local ids_key = vRP.getSourceIdKey(source)
  local user = self.users_by_source[source]
  local pending = false
  if not user then -- pending user check
    user = self.pending_users[ids_key]
    pending = true
  end

  if user then
    if pending then 
      self.users_by_source[user.source] = nil -- remove old entry
      user.source = source -- update source
      self.users_by_source[source] = user -- new entry
      self.pending_users[ids_key] = nil -- remove from pending
    end

    user.spawns = user.spawns+1
    local first_spawn = (user.spawns == 1)

    if first_spawn then
      -- first spawn, reference player
      -- send players to new player
      for k,v in pairs(self.users) do
        self.EXT.Base.remote._addPlayer(source,v.source)
      end
      -- send new player to all players
      self.EXT.Base.remote._addPlayer(-1,user.source)

      -- set client tunnel delay at first spawn
      Tunnel.setDestDelay(source, self.cfg.load_delay)

      -- show loading
--      vRPclient._setProgressBar(user.source, "vRP:loading", "botright", "Loading...", 0,0,0, 100)

      SetTimeout(2000, function() 
        SetTimeout(self.cfg.load_duration*1000, function() -- set client delay to normal delay
          Tunnel.setDestDelay(source, self.cfg.global_delay)
--          vRPclient._removeProgressBar(user.source,"vRP:loading")
        end)
      end)
    end

    SetTimeout(2000, function() -- trigger spawn event
      self:triggerEvent("playerSpawn", user)
    end)
  end
end

function vRP:onPlayerDropped(source)
  Debug.log("playerDropped "..source)
  self:dropPlayer(source)
end

return vRP
