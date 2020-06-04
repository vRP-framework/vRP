-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.ped_blacklist then return end

local PedBlacklist = class("PedBlacklist", vRP.Extension)

function PedBlacklist:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/ped_blacklist")
end

-- EVENT
PedBlacklist.event = {}

function PedBlacklist.event:playerSpawn(user, first_spawn)
  if first_spawn then
    self.remote._setConfig(user.source, self.cfg)
  end
end

vRP:registerExtension(PedBlacklist)
