-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.veh_blacklist then return end

local VehBlacklist = class("VehBlacklist", vRP.Extension)

-- METHODS

function VehBlacklist:__construct()
  vRP.Extension.__construct(self)

  self.veh_models = {} -- map of model hash
  self.interval = 10000

  -- task: remove vehicles
  Citizen.CreateThread(function()
    while true do 
      Citizen.Wait(self.interval)

      local vehicles = {}

      local it, veh = FindFirstVehicle()
      if veh then table.insert(vehicles, veh) end

      while true do
        local ok, veh = FindNextVehicle(it)
        if ok and veh then 
          table.insert(vehicles, veh) 
        else
          EndFindVehicle(it)
          break
        end
      end

      for _, veh in ipairs(vehicles) do
        if self.veh_models[GetEntityModel(veh)] then
          local cid, model = vRP.EXT.Garage:getVehicleInfo(veh)
          if not cid then
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
          end
        end
      end
    end
  end)
end

-- TUNNEL
VehBlacklist.tunnel = {}

function VehBlacklist.tunnel:setConfig(cfg)
  for _, model in pairs(cfg.veh_models) do
    local hash
    if type(model) == "string" then
      hash = GetHashKey(model)
    else
      hash = model
    end

    self.veh_models[hash] = true
  end

  self.interval = cfg.remove_interval
end

vRP:registerExtension(VehBlacklist)
