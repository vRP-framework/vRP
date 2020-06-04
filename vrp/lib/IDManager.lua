-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

local IDManager = class("IDManager")

function IDManager:__construct()
  self:clear()
end

function IDManager:clear()
  self.max = 0
  self.ids = {}
end

-- return a new id
function IDManager:gen()
  if #self.ids > 0 then
    return table.remove(self.ids)
  else
    local r = self.max
    self.max = self.max+1
    return r
  end
end

-- free a previously generated id
function IDManager:free(id)
  table.insert(self.ids,id)
end

return IDManager
