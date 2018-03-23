
local Tools = module("vrp", "lib/Tools")

local Debug = {}

if SERVER then
  local cfg = module("vrp", "cfg/base")
  Debug.active = cfg.debug
  Debug.async_time = cfg.debug_async_time or 2
end
Debug.maxlen = 75

local profile_ids = Tools.newIDGenerator()
local profiles = {}

function Debug.log(str, no_limit)
  if Debug.active then
    if not no_limit and string.len(str) > Debug.maxlen then
      str = string.sub(str,1,Debug.maxlen).."..."
    end

    print("[vRP Debug] "..str)
  end
end

-- begin profile
function Debug.pbegin(str)
  if not max_time then
    max_time = 2
  end

  if Debug.active then
    local id = profile_ids:gen()
    profiles[id] = {os.clock(), str}
    return id
  end
end

-- end profile
function Debug.pend(id)
  if Debug.active then
    local profile = profiles[id]
    if profile then
      Debug.log("profiled "..profile[2].." = "..(math.floor((os.clock()-profile[1])*1000)/1000).."s", true)
      profiles[id] = nil
      profile_ids:free(id)
    end
  end
end

-- copy table without userdata
function Debug.safeTableCopy(t)
  local r = t

  if type(t) == "table" then
    r = {}
    for k,v in pairs(t) do
      if type(v) ~= "userdata" then
        r[k] = Debug.safeTableCopy(v)
      end
    end
  end

  return r
end

return Debug
