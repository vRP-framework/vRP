-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.profiler then return end

local ELProfiler = module("vrp", "lib/ELProfiler")
local lang = vRP.lang
local Profiler = class("Profiler", vRP.Extension)

local function prompt_options(user)
  local options = {period = 0.01, resources = {}}
  local str = user:prompt(lang.profiler.prompt_resources(), "")
  for rsc in string.gmatch(str, "[^%s]+") do options.resources[rsc] = true end
  options.duration = tonumber(user:prompt(lang.profiler.prompt_duration(), "30")) or 30
  options.stack_depth = tonumber(user:prompt(lang.profiler.prompt_stack_depth(), "1")) or 1
  options.aggregate = not not user:prompt(lang.profiler.prompt_aggregate(), "no"):find("yes")
  return options
end

-- return formatted string
local function process_data(options, profiles)
  local strs = {}
  if options.aggregate then -- single aggregate profile
    local agg_samples = {}
    for rsc, profile in pairs(profiles) do
      for entry, samples in pairs(profile.samples) do
        agg_samples[entry] = (agg_samples[entry] or 0)+samples
      end
    end
    -- remove missed samples
    agg_samples["?"] = nil
    -- count
    local total_samples = 0
    for entry, samples in pairs(agg_samples) do
      total_samples = total_samples+samples
    end
    -- recompute missed samples
    local missed = math.max(math.floor(options.duration/options.period)-total_samples, 0)
    agg_samples["?"] = missed
    -- build profile
    local profile = {
      duration = options.duration,
      samples_count = total_samples+missed,
      samples = agg_samples
    }
    table.insert(strs, ELProfiler.format(profile))
  else -- all profiles
    for rsc, profile in pairs(profiles) do
      table.insert(strs, rsc.."\n")
      table.insert(strs, ELProfiler.format(profile))
      table.insert(strs, "\n")
    end
  end
  return table.concat(strs)
end

function Profiler:__construct()
  vRP.Extension.__construct(self)
  self.task_count = 0
  self.profile_tasks = {}

  -- handle profile results
  RegisterNetEvent("vRP:profile:res")
  AddEventHandler("vRP:profile:res", function(id, rsc_name, profile)
    local task = self.profile_tasks[id]
    if task then task(rsc_name, profile) end
  end)

  -- admin menu
  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    if menu.user:hasPermission("profiler.server") then
      menu:addOption(lang.profiler.title_server(), function(menu)
        local options = prompt_options(menu.user)
        local profiles = {}
        self.task_count = self.task_count+1
        local id = self.task_count
        self.profile_tasks[id] = function(rsc_name, profile)
          profiles[rsc_name] = profile
        end
        TriggerEvent("vRP:profile", id, options)
        Citizen.Wait((options.duration+5)*1000) -- wait profiles
        menu.user:prompt(lang.profiler.prompt_report(), process_data(options, profiles))
        self.profile_tasks[id] = nil
      end)
    end
  end)
  -- main menu
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    if menu.user:hasPermission("profiler.client") then
      menu:addOption(lang.profiler.title_client(), function(menu)
        local user = menu.user
        local options = prompt_options(user)
        local profiles = {}
        self.task_count = self.task_count+1
        local id = self.task_count
        self.profile_tasks[id] = function(rsc_name, profile)
          profiles[rsc_name] = profile
        end
        TriggerClientEvent("vRP:profile", user.source, id, options)
        Citizen.Wait((options.duration+5)*1000) -- wait profiles
        user:prompt(lang.profiler.prompt_report(), process_data(options, profiles))
        self.profile_tasks[id] = nil
      end)
    end
  end)
end

vRP:registerExtension(Profiler)
