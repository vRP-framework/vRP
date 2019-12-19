-- this file define global tools required by vRP and vRP extensions
-- it will create module, SERVER, CLIENT, async, class...

-- side detection
SERVER = IsDuplicityVersion()
CLIENT = not SERVER

-- table.maxn replacement
function table_maxn(t)
  local max = 0
  for k,v in pairs(t) do
    local n = tonumber(k)
    if n and n > max then max = n end
  end

  return max
end

local modules = {}

-- load a lua resource file as module (for a specific side)
-- rsc: resource name
-- path: lua file path without extension
function module(rsc, path)
  if path == nil then -- shortcut for vrp, can omit the resource parameter
    path = rsc
    rsc = "vrp"
  end

  local key = rsc..path

  local module = modules[key]
  if module then -- cached module
    return module
  else
    local code = LoadResourceFile(rsc, path..".lua")
    if code then
      local f,err = load(code, rsc.."/"..path..".lua")
      if f then
        local ok, res = xpcall(f, debug.traceback)
        if ok then
          modules[key] = res
          return res
        else
          error("error loading module "..rsc.."/"..path..":"..res)
        end
      else
        error("error parsing module "..rsc.."/"..path..":"..debug.traceback(err))
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
  local rets = Citizen.Await(self.p)
  if not rets then
    if self.r then
      rets = self.r
    else
      error("async wait(): Citizen.Await returned (nil) before the areturn call.")
    end
  end

  return table.unpack(rets, 1, table_maxn(rets))
end

local function areturn(self, ...)
  self.r = {...}
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
--  return cast(int,tonumber(v))
  local n = tonumber(v)
  if n == nil then 
    return 0
  else
    return math.floor(n)
  end
end

function parseDouble(v)
--  return cast(double,tonumber(v))
  local n = tonumber(v)
  if n == nil then n = 0 end
  return n
end

function parseFloat(v)
  return parseDouble(v)
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
