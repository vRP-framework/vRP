-- init vRP server context

local Luaoop = module("vrp", "lib/Luaoop")
class = Luaoop.class
Proxy = module("lib/Proxy")
Tunnel = module("lib/Tunnel")
Debug = module("lib/Debug")

local cvRP = module("vrp", "vRP")
vRP = cvRP() -- instantiate vRP

local pvRP = {}
-- load script in vRP context
function pvRP.loadScript(resource, path)
  module(resource, path)
end

Proxy.addInterface("vRP", pvRP)

-- queries
vRP:prepare("vRP/base_tables",[[
CREATE TABLE IF NOT EXISTS vrp_users(
  id INTEGER AUTO_INCREMENT,
  whitelisted BOOLEAN,
  banned BOOLEAN,
  CONSTRAINT pk_user PRIMARY KEY(id)
);

CREATE TABLE IF NOT EXISTS vrp_user_ids(
  identifier VARCHAR(100),
  user_id INTEGER,
  CONSTRAINT pk_user_ids PRIMARY KEY(identifier),
  CONSTRAINT fk_user_ids_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS vrp_characters(
  id INTEGER AUTO_INCREMENT,
  user_id INTEGER,
  CONSTRAINT pk_characters PRIMARY KEY(id),
  CONSTRAINT fk_characters_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS vrp_user_data(
  user_id INTEGER,
  dkey VARCHAR(100),
  dvalue BLOB,
  CONSTRAINT pk_user_data PRIMARY KEY(user_id,dkey),
  CONSTRAINT fk_user_data_users FOREIGN KEY(user_id) REFERENCES vrp_users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS vrp_character_data(
  character_id INTEGER,
  dkey VARCHAR(100),
  dvalue BLOB,
  CONSTRAINT pk_character_data PRIMARY KEY(character_id,dkey),
  CONSTRAINT fk_character_data_characters FOREIGN KEY(character_id) REFERENCES vrp_characters(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS vrp_server_data(
  id VARCHAR(100),
  dkey VARCHAR(100),
  dvalue BLOB,
  CONSTRAINT pk_server_data PRIMARY KEY(id, dkey)
);
]])

vRP:prepare("vRP/create_user","INSERT INTO vrp_users(whitelisted,banned) VALUES(false,false); SELECT LAST_INSERT_ID() AS id")

vRP:prepare("vRP/create_character", "INSERT INTO vrp_characters(user_id) VALUES(@user_id); SELECT LAST_INSERT_ID() AS id")
vRP:prepare("vRP/delete_character", "DELETE FROM vrp_characters WHERE id = @id AND user_id = @user_id")
vRP:prepare("vRP/get_characters", "SELECT id FROM vrp_characters WHERE user_id = @user_id")
vRP:prepare("vRP/check_character", "SELECT id FROM vrp_characters WHERE id = @id AND user_id = @user_id")

vRP:prepare("vRP/add_identifier","INSERT INTO vrp_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
vRP:prepare("vRP/userid_byidentifier","SELECT user_id FROM vrp_user_ids WHERE identifier = @identifier")

vRP:prepare("vRP/set_userdata","REPLACE INTO vrp_user_data(user_id,dkey,dvalue) VALUES(@user_id,@key,UNHEX(@value))")
vRP:prepare("vRP/get_userdata","SELECT dvalue FROM vrp_user_data WHERE user_id = @user_id AND dkey = @key")
vRP:prepare("vRP/set_characterdata","REPLACE INTO vrp_character_data(character_id,dkey,dvalue) VALUES(@character_id,@key,UNHEX(@value))")
vRP:prepare("vRP/get_characterdata","SELECT dvalue FROM vrp_character_data WHERE character_id = @character_id AND dkey = @key")


vRP:prepare("vRP/set_serverdata","REPLACE INTO vrp_server_data(id,dkey,dvalue) VALUES(@id,@key,UNHEX(@value))")
vRP:prepare("vRP/get_serverdata","SELECT dvalue FROM vrp_server_data WHERE id = @id AND dkey = @key")

vRP:prepare("vRP/get_banned","SELECT banned FROM vrp_users WHERE id = @user_id")
vRP:prepare("vRP/set_banned","UPDATE vrp_users SET banned = @banned WHERE id = @user_id")
vRP:prepare("vRP/get_whitelisted","SELECT whitelisted FROM vrp_users WHERE id = @user_id")
vRP:prepare("vRP/set_whitelisted","UPDATE vrp_users SET whitelisted = @whitelisted WHERE id = @user_id")

-- init tables
async(function()
  vRP:execute("vRP/base_tables")
end)

-- handlers

AddEventHandler("playerConnecting",function(name, setMessage, deferrals)
  vRP:onPlayerConnecting(source, name, setMessage, deferrals)
end)

AddEventHandler("playerDropped",function(reason)
  vRP:onPlayerDropped(source)
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned", function()
  vRP:onPlayerSpawned(source)
end)

local lang = vRP.lang

-- Base extension

local Base = class("Base", vRP.Extension)

-- EVENT

Base.event = {}

function Base.event:playerSpawn(user, first_spawn)
  -- notify last login
  if user.last_login then
    SetTimeout(15000,function()
      self.remote._notify(user.source,lang.common.welcome({user.last_login}))
    end)
  end
end

vRP:registerExtension(Base)
