-- load User extensions

local extensions = {}

for name,ext in pairs(vRP.EXT) do
  if class.is(ext.User) then -- is a class
    table.insert(extensions, ext.User)
  end
end

-- User class

local User = class("User", extensions)

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

return User
