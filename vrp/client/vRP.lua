
local vRPShared = module("vrp", "vRPShared")

-- Client vRP
local vRP = class("vRP", vRPShared)

function vRP:__construct()
  vRPShared.__construct(self)

  -- load config
  self.cfg = module("vrp", "cfg/client")
end

return vRP
