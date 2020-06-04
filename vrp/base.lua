-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

-- init vRP server context

Proxy = module("lib/Proxy")
Tunnel = module("lib/Tunnel")

local htmlEntities = module("vrp", "lib/htmlEntities")

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

CREATE TABLE IF NOT EXISTS vrp_global_data(
  dkey VARCHAR(100),
  dvalue BLOB,
  CONSTRAINT pk_global_data PRIMARY KEY(dkey)
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

vRP:prepare("vRP/set_globaldata","REPLACE INTO vrp_global_data(dkey,dvalue) VALUES(@key,UNHEX(@value))")
vRP:prepare("vRP/get_globaldata","SELECT dvalue FROM vrp_global_data WHERE dkey = @key")


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

RegisterServerEvent("vRPcli:playerDied")
AddEventHandler("vRPcli:playerDied", function()
  vRP:onPlayerDied(source)
end)

local lang = vRP.lang

-- Base extension

local Base = class("Base", vRP.Extension)

-- PRIVATE METHODS

-- menu: characters
local function menu_characters(self)
  local function m_use(menu, cid)
    local user = menu.user
    local ok, err = user:useCharacter(cid)
    if not ok then
      if err <= 2 then
        self.remote._notify(user.source, lang.common.must_wait({user.use_character_action:remaining()}))
      else
        self.remote._notify(user.source, lang.characters.character.error())
      end
    end
  end

  local function m_create(menu)
    local user = menu.user
    if user:createCharacter() then
      user:actualizeMenu()
    else
      self.remote._notify(user.source, lang.characters.create.error())
    end
  end

  local function m_delete(menu)
    local user = menu.user

    local cid = parseInt(user:prompt(lang.characters.delete.prompt(), ""))
    if user:deleteCharacter(cid) then
      user:actualizeMenu()
    else
      self.remote._notify(user.source, lang.characters.delete.error({cid}))
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("characters", function(menu)
    local user = menu.user
    menu.title = lang.characters.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    -- characters
    local characters = user:getCharacters()
    for _, cid in pairs(characters) do
      local identity = vRP.EXT.Identity:getIdentity(cid)
      local prefix
      if cid == user.cid then prefix = "* " else prefix = "" end

      menu:addOption(prefix..lang.characters.character.title({cid, htmlEntities.encode(identity and identity.name or ""), htmlEntities.encode(identity and identity.firstname or "")}), m_use, nil, cid)
    end

    menu:addOption(lang.characters.create.title(), m_create)
    menu:addOption(lang.characters.delete.title(), m_delete)
  end)
end

-- EVENT

Base.event = {}

function Base.event:extensionLoad(ext)
  if ext == vRP.EXT.GUI then
    menu_characters(self)

    local function m_characters(menu)
      menu.user:openMenu("characters")
    end

    vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
      if menu.user:hasPermission("player.characters") then
        menu:addOption(lang.characters.title(), m_characters)
      end
    end)
  elseif ext == vRP.EXT.Group then
    -- register fperm inside
    vRP.EXT.Group:registerPermissionFunction("inside", function(user, params)
      return self.remote.isInside(user.source)
    end)
  end
end

function Base.event:characterLoad(user)
  self.remote._setCharacterId(user.source, user.cid)
end

function Base.event:playerSpawn(user, first_spawn)
  if first_spawn then
    self.remote._setUserId(user.source, user.id)
    self.remote._setCharacterId(user.source, user.cid)

    -- notify last login
    if user.last_login then
      SetTimeout(15000,function()
        self.remote._notify(user.source,lang.common.welcome({user.last_login}))
      end)
    end
  end
end

vRP:registerExtension(Base)
