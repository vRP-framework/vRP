-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

-- This file define global tools required by vRP and vRP extensions.

-- side detection
SERVER = IsDuplicityVersion()
CLIENT = not SERVER

local modules = {}

-- load a lua resource file as module (for a specific side)
-- rsc: resource name
-- path: lua file path without extension
function module(rsc, path)
  if not path then -- shortcut for vrp, can omit the resource parameter
    path = rsc
    rsc = "vrp"
  end
  local key = rsc.."/"..path
  local rets = modules[key]
  if rets then -- cached module
    return table.unpack(rets, 2, rets.n)
  else
    local code = LoadResourceFile(rsc, path..".lua")
    if code then
      local f, err = load(code, rsc.."/"..path..".lua")
      if f then
        local rets = table.pack(xpcall(f, debug.traceback))
        if rets[1] then
          modules[key] = rets
          return table.unpack(rets, 2, rets.n)
        else
          error("error loading module "..rsc.."/"..path..": "..rets[2])
        end
      else
        error("error parsing module "..rsc.."/"..path..": "..err)
      end
    else
      error("resource file "..rsc.."/"..path..".lua not found")
    end
  end
end

-- Luaoop class

local Luaoop = module("vrp", "lib/Luaoop")
class = Luaoop.class

-- Luaseq like for FiveM

local function wait(self)
  local r = Citizen.Await(self.p)
  if not r then
    if self.r then
      r = self.r
    else
      error("async wait(): Citizen.Await returned (nil) before the areturn call.")
    end
  end
  return table.unpack(r, 1, r.n)
end

local function areturn(self, ...)
  self.r = table.pack(...)
  self.p:resolve(self.r)
end

-- create an async returner or a thread (Citizen.CreateThreadNow)
-- func: if passed, will create a thread, otherwise will return an async returner
function async(func)
  if func then
    Citizen.CreateThreadNow(func)
  else
    return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
  end
end

-- Profiling.
local cfg_modules = module("vrp", "cfg/modules")
if cfg_modules.profiler then
  -- load profiler
  local ELProfiler
  if not os then -- fix missing os lib error
    os = {}; ELProfiler = module("vrp", "lib/ELProfiler"); os = nil
  else
    ELProfiler = module("vrp", "lib/ELProfiler")
  end
  -- set clock
  ELProfiler.setClock(function() return GetGameTimer()/1000 end)
  -- patch coroutine.create to profile coroutines
  local create = coroutine.create
  coroutine.create = function(...)
    local thread = create(...)
    ELProfiler.watch(thread)
    return thread
  end
  -- watch main thread
  ELProfiler.watch(coroutine.running())
  -- listen to profile requests
  local rsc_name = GetCurrentResourceName()
  if CLIENT then RegisterNetEvent("vRP:profile") end
  local running = false
  AddEventHandler("vRP:profile", function(id, options)
    -- all or specific resources
    if not running and (not next(options.resources) or options.resources[rsc_name]) then
      running = true -- guard
      ELProfiler.start(options.period, options.stack_depth)
      Citizen.Wait(options.duration*1000)
      local trigger = CLIENT and TriggerServerEvent or TriggerEvent
      trigger("vRP:profile:res", id, rsc_name, ELProfiler.stop())
      running = false
    end
  end)
end

local function hex_conv(c)
  return string.format('%02X', string.byte(c))
end

-- convert Lua string to hexadecimal
function tohex(str)
  return string.gsub(str, '.', hex_conv)
end

-- basic deep clone function (doesn't handle circular references)
function clone(t)
  if type(t) == "table" then
    local new = {}
    for k,v in pairs(t) do
      new[k] = clone(v)
    end
    return new
  else
    return t
  end
end

function parseInt(v)
  local n = tonumber(v)
  if n == nil then 
    return 0
  else
    return math.floor(n)
  end
end

-- will remove chars not allowed/disabled by strchars
-- allow_policy: if true, will allow all strchars, if false, will allow everything except the strchars
local sanitize_tmp = {}
function sanitizeString(str, strchars, allow_policy)
  local r = ""
  -- get/prepare index table
  local chars = sanitize_tmp[strchars]
  if chars == nil then
    chars = {}
    local size = string.len(strchars)
    for i=1,size do
      local char = string.sub(strchars,i,i)
      chars[char] = true
    end

    sanitize_tmp[strchars] = chars
  end
  -- sanitize
  size = string.len(str)
  for i=1,size do
    local char = string.sub(str,i,i)
    if (allow_policy and chars[char]) or (not allow_policy and not chars[char]) then
      r = r..char
    end
  end
  return r
end

function splitString(str, sep)
  if sep == nil then sep = "%s" end
  local t={}
  local i=1
  for str in string.gmatch(str, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end
