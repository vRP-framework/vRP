-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)


local vRPShared = module("vrp", "vRPShared")

-- Client vRP
local vRP = class("vRP", vRPShared)

function vRP:__construct()
  vRPShared.__construct(self)

  -- load config
  self.cfg = module("vrp", "cfg/client")
end

return vRP
