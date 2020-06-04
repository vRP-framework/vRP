-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.veh_blacklist then return end

local VehBlacklist = class("VehBlacklist", vRP.Extension)

function VehBlacklist:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/veh_blacklist")
end

-- EVENT
VehBlacklist.event = {}

function VehBlacklist.event:playerSpawn(user, first_spawn)
  if first_spawn then
    self.remote._setConfig(user.source, self.cfg)
  end
end

vRP:registerExtension(VehBlacklist)
