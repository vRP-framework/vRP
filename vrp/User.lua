-- load User extensions

local extensions = {}

for name,ext in pairs(vRP.EXT) do
  if class.is(ext.User) then -- is a class
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

  -- extensions constructors
  for _,uext in pairs(extensions) do
    local construct = uext.__construct
    if construct then
      construct(self)
    end
  end
end

function User:save()
  vRP:setUData(self.id, "vRP:datatable", msgpack.pack(self.data))
  vRP:setCData(self.cid, "vRP:datatable", msgpack.pack(self.cdata))
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
-- return true or false on failure
function User:useCharacter(id)
  if id == self.cid then return true end

  local rows = vRP:query("vRP/check_character", {user_id = self.id, id = id})
  if #rows > 0 then
    -- unload character
    if self.cid then 
      vRP.users_by_cid[self.cid] = nil -- reference
      vRP:triggerEventSync("characterUnload", self)

      vRP:setCData(self.cid, "vRP:datatable", msgpack.pack(self.cdata))
    end

    self.cid = id
    self.data.current_character = id
    vRP.users_by_cid[self.cid] = self -- reference

    -- load character
    self.cdata = {}
    local sdata = vRP:getCData(self.cid, "vRP:datatable")
    if sdata and string.len(sdata) > 0 then
      self.cdata = msgpack.unpack(sdata)
    end

    vRP:triggerEventSync("characterLoad", self)

    if self.spawns > 0 then -- trigger respawn if already spawned
      vRP.EXT.Base.remote._triggerRespawn(self.source)
    end

    return true
  end

  return false
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
