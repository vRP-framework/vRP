-- PROXY CLIENT-SIDE VERSION (https://github.com/ImagicTheCat/vRP)
-- Proxy interface system, used to add/call functions between resources
Proxy = {}

local proxy_rdata = {}
local function proxy_callback(rvalues) -- save returned values, TriggerEvent is synchronous
  proxy_rdata = rvalues
end

local function proxy_resolve(itable,key)
  local iname = getmetatable(itable).name

  -- generate access function
  local fcall = function(args,callback)
    if args == nil then
      args = {}
    end

    TriggerEvent(iname..":proxy",key,args,proxy_callback)
    return table.unpack(proxy_rdata) -- returns
  end

  itable[key] = fcall -- add generated call to table (optimization)
  return fcall
end

--- Add event handler to call interface functions (can be called multiple times for the same interface name with different tables)
function Proxy.addInterface(name, itable)
  AddEventHandler(name..":proxy",function(member,args,callback)
    local f = itable[member]

    if type(f) == "function" then
      callback({f(table.unpack(args))}) -- call function with and return values through callback
      -- CancelEvent() -- cancel event doesn't seem to cancel the event for the other handlers, but if it does, uncomment this
    else
      -- print("error: proxy call "..name..":"..member.." not found")
    end
  end)
end

function Proxy.getInterface(name)
  local r = setmetatable({},{ __index = proxy_resolve, name = name })
  return r
end

-- END PROXY CLIENT-SIDE VERSION
