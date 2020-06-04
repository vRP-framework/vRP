-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

local ActionDelay = module("vrp", "lib/ActionDelay")

-- load User extensions

local extensions = {}

for name,ext in pairs(vRP.EXT) do
  if class.type(ext.User) == ext.User then -- is a class
    table.insert(extensions, ext.User)
  end
end

-- User class

local User = class("User", table.unpack(extensions))

function User:__construct(source, id)
  self.source = source
  self.id = id
  self.endpoint = "0.0.0.0"
  self.data = {}
  self.loading_character = false
  self.use_character_action = ActionDelay()

  -- extensions constructors
  for _,uext in pairs(extensions) do
    local construct = uext.__construct
    if construct then
      construct(self)
    end
  end
end

-- return true if the user character is ready (loaded, not loading)
function User:isReady()
  return self.cid and not self.loading_character
end

function User:save()
  vRP:setUData(self.id, "vRP:datatable", msgpack.pack(self.data))

  if not self.loading_character then
    vRP:setCData(self.cid, "vRP:datatable", msgpack.pack(self.cdata))
  end
end

-- return characters id list
function User:getCharacters()
  local characters = {}
  
  local rows = vRP:query("vRP/get_characters", {user_id = self.id})
  for _,row in ipairs(rows) do
    table.insert(characters, row.id)
  end

  return characters
end

-- return created character id or nil if failed
function User:createCharacter()
  local characters = self:getCharacters()
  if #characters < vRP.cfg.max_characters then
    local rows = vRP:query("vRP/create_character", {user_id = self.id})
    if #rows > 0 then
      return rows[1].id
    end
  end
end

-- use character
-- return true or false, err_code
-- err_code: 
--- 1: delay error, too soon
--- 2: already loading
--- 3: invalid character
function User:useCharacter(id)
  if id == self.cid then return true end -- same check

  -- delay check
  if self.use_character_action:remaining() > 0 then return false, 1 end

  if self.loading_character then return false, 2 end -- loading check

  local rows = vRP:query("vRP/check_character", {user_id = self.id, id = id})
  if #rows > 0 then
    -- unload character
    if self.cid then 
      vRP:triggerEventSync("characterUnload", self)
      vRP.users_by_cid[self.cid] = nil -- reference

      vRP:setCData(self.cid, "vRP:datatable", msgpack.pack(self.cdata))
    end

    self.cid = id
    self.data.current_character = id
    vRP.users_by_cid[self.cid] = self -- reference
    self.loading_character = true

    -- load character
    self.cdata = {}
    local sdata = vRP:getCData(self.cid, "vRP:datatable")
    if sdata and string.len(sdata) > 0 then
      self.cdata = msgpack.unpack(sdata)
    end

    vRP:triggerEventSync("characterLoad", self)
    self.loading_character = false

    self.use_character_action:perform(vRP.cfg.character_select_delay)

    if self.spawns > 0 then -- trigger respawn if already spawned
      vRP.EXT.Base.remote._triggerRespawn(self.source)
    end


    return true
  end

  return false, 3
end

-- delete character
-- return true or false on failure
function User:deleteCharacter(id)
  if self.cid ~= id then -- don't delete used character
    local affected = vRP:execute("vRP/delete_character", {user_id = self.id, id = id})
    if affected > 0 then
      return true
    end
  end

  return false
end

return User
