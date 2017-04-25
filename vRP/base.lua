
local MySQL = require("resources/vRP/lib/MySQL/MySQL")
local config = require("resources/vRP/cfg/main")

vRP = {}
vRP.users = {} -- will store logged users (id) by first identifier
vRP.rusers = {} -- store the opposite of users

-- open MySQL connection
vRP.sql = MySQL.open(config.db.host,config.db.user,config.db.password,config.db.database)

-- queries
local q_init = vRP.sql:prepare([[
CREATE TABLE IF NOT EXISTS vrp_users(
  id INTEGER AUTO_INCREMENT,
  CONSTRAINT pk_user PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS vrp_user_ids(
  identifier VARCHAR(255),
  user_id INTEGER,
  CONSTRAINT pk_user_ids PRIMARY KEY(identifier),
  CONSTRAINT fk_user_ids_user FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);
]])

local q_create_user = vRP.sql:prepare("INSERT INTO vrp_users VALUES();")
local q_add_identifier = vRP.sql:prepare("INSERT INTO vrp_user_ids(identifier,user_id) VALUES(@identifier,@user_id);")
local q_userid_byidentifier = vRP.sql:prepare("SELECT user_id FROM vrp_user_ids WHERE identifier = @identifier;")

-- init tables
print("[vRP] init base tables")
q_init:execute()

-- base events
RegisterServerEvent("vRP:playerJoin")
RegisterServerEvent("vRP:playerLeave")

-- identification system

--- sql.
-- @return user id or nil if not found
function vRP.getUserIdByIdentifiers(ids)
  if ids ~= nil then
    for k,v in pairs(ids) do
      q_userid_byidentifier:bind("@identifier",v)

      local r = q_userid_byidentifier:query()
      if r:fetch() then
        return r:getValue("user_id")
      end
    end
  end

  return nil
end

--- sql.
-- @return new user id or nil if not created
function vRP.registerUser(ids)
  if ids ~= nil and #ids > 0 then
    -- create user
    q_create_user:execute()
    local id = q_create_user:last_insert_id()

    -- add identifiers
    q_add_identifier:bind("@user_id",id)

    for k,v in pairs(ids) do
      q_add_identifier:bind("@identifier",v)
      q_add_identifier:execute()
    end

    return id
  end

  return nil
end

function vRP.getUserId(source)
  local ids = GetPlayerIdentifiers(source)
  if ids ~= nil and #ids > 0 then
    return vRP.users[ids[1]]
  end

  return nil
end

-- handlers
AddEventHandler("playerConnecting",function(name,setMessage)
  local ids = GetPlayerIdentifiers(source)
  
  if ids ~= nil and #ids > 0 then
    local user_id = vRP.getUserIdByIdentifiers(ids)
    if user_id == nil then
      vRP.registerUser(ids)
      -- redo getUserIdByIdentifiers, there is a strange TriggerEvent issue with the id returned by registerUser
      user_id = vRP.getUserIdByIdentifiers(ids)
    end

    if user_id ~= nil and vRP.rusers[user_id] == nil then -- check user validity and if not already connected
      vRP.users[ids[1]] = user_id
      vRP.rusers[user_id] = ids[1]

      print("[vRP] "..name.." ("..GetPlayerEP(source)..") joined (user_id = "..user_id..")")
      TriggerEvent("vRP:playerJoin", user_id, source, name)
    else
      print("[vRP] "..name.." ("..GetPlayerEP(source)..") rejected: identification error (already connected ?)")
      setMessage("[vRP] Identification error (already connected ?).")
      CancelEvent()
    end
  else
    print("[vRP] "..name.." ("..GetPlayerEP(source)..") rejected: missing identifiers")
    setMessage("[vRP] Missing identifiers.")
    CancelEvent()
  end
end)

AddEventHandler("playerDropped",function(reason)
  local user_id = vRP.getUserId(source)

  if user_id ~= nil then
    TriggerEvent("vRP:playerLeave", user_id, source)
    print("[vRP] "..GetPlayerEP(source).." disconnected (user_id = "..user_id..")")
    vRP.users[vRP.rusers[user_id]] = nil
    vRP.rusers[user_id] = nil
  end
end)
