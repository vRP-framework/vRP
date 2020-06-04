-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)


if not vRP.modules.warp then return end

local Warp = class("Warp", vRP.Extension)
local ActionDelay = module("lib/ActionDelay")

-- SUBCLASS

Warp.User = class("User")

function Warp.User:__construct()
  self.warp_action = ActionDelay()
end

-- METHODS

function Warp:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/warps")
end

-- EVENT
Warp.event = {}

function Warp.event:playerSpawn(user, first_spawn)
  if first_spawn then
    for k,v in pairs(self.cfg.warps) do
      local pos,target,cfg = table.unpack(v)
      if not cfg then cfg = {} end

      local mode = cfg.mode or 0
      local map_entity = cfg.map_entity or self.cfg.default_map_entities[mode]
      local x,y,z = table.unpack(pos)

      local function enter(user)
        if user:hasPermissions(cfg.permissions or {}) then
          local in_vehicle = vRP.EXT.Garage.remote.isInVehicle(user.source)
          if in_vehicle and mode >= 1 and user.warp_action:perform(self.cfg.warp_delay) then
            vRP.EXT.Base.remote._vehicleTeleport(user.source,table.unpack(target))
          elseif not in_vehicle and (mode == 0 or mode == 2) and user.warp_action:perform(self.cfg.warp_delay) then
            vRP.EXT.Base.remote._teleport(user.source,table.unpack(target))
          end
        end
      end

      local ment = clone(map_entity)
      ment[2].pos = {x,y,z-1}
      vRP.EXT.Map.remote._addEntity(user.source, ment[1], ment[2])

      user:setArea("vRP:warp:"..k,x,y,z,1.5,1.5,enter)
    end
  end
end

vRP:registerExtension(Warp)
