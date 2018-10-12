local User = class("User")

function User:__construct(vRP, source, id)
  self.vRP = vRP
  self.source = source
  self.id = id
  self.endpoint = "0.0.0.0"
  self.data = {}
end

return User
