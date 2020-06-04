-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.ped_blacklist then return end

local PedBlacklist = class("PedBlacklist", vRP.Extension)

-- METHODS

function PedBlacklist:__construct()
  vRP.Extension.__construct(self)

  self.ped_models = {} -- map of model hash
  self.interval = 10000

  -- task: remove peds
  Citizen.CreateThread(function()
    while true do 
      Citizen.Wait(self.interval)

      local peds = {}

      local it, ped = FindFirstPed()
      if ped then table.insert(peds, ped) end

      while true do
        local ok, ped = FindNextPed(it)
        if ok and ped then 
          table.insert(peds, ped) 
        else
          EndFindPed(it)
          break
        end
      end

      for _, ped in ipairs(peds) do
        if not IsPedAPlayer(ped) and self.ped_models[GetEntityModel(ped)] then
          DeletePed(Citizen.PointerValueIntInitialized(ped))
        end
      end
    end
  end)
end

-- TUNNEL
PedBlacklist.tunnel = {}

function PedBlacklist.tunnel:setConfig(cfg)
  for _, model in pairs(cfg.ped_models) do
    local hash
    if type(model) == "string" then
      hash = GetHashKey(model)
    else
      hash = model
    end

    self.ped_models[hash] = true
  end

  self.interval = cfg.remove_interval
end

vRP:registerExtension(PedBlacklist)
