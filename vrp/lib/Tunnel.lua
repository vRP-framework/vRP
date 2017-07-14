
local Tools = module("lib/Tools")
local Debug = module("lib/Debug")

-- this file describe a two way proxy between the server and the clients (request system)

local Tunnel = {}

-- define per dest regulator
Tunnel.delays = {}

-- set the base delay between Triggers for this destination in milliseconds (0 for instant trigger)
function Tunnel.setDestDelay(dest, delay)
  Tunnel.delays[dest] = {delay, 0}
end

local function tunnel_resolve(itable,key)
  local mtable = getmetatable(itable)
  local iname = mtable.name
  local ids = mtable.tunnel_ids
  local callbacks = mtable.tunnel_callbacks
  local identifier = mtable.identifier

  -- generate access function
  local fcall = function(dest,args,callback)
    if args == nil then
      args = {}
    end

    -- get delay data
    local delay_data = Tunnel.delays[dest]
    if delay_data == nil then
      delay_data = {0,0}
    end

    -- increase delay
    local add_delay = delay_data[1]
    delay_data[2] = delay_data[2]+add_delay

    if delay_data[2] > 0 then -- delay trigger
      SetTimeout(delay_data[2], function() 
        -- remove added delay
        delay_data[2] = delay_data[2]-add_delay

        -- send request
        if type(callback) == "function" then -- ref callback if exists (become a request)
          local rid = ids:gen()
          callbacks[rid] = callback
          TriggerClientEvent(iname..":tunnel_req",dest,key,args,identifier,rid)
        else -- regular trigger
          TriggerClientEvent(iname..":tunnel_req",dest,key,args,"",-1)
        end
      end)
    else -- no delay
      -- send request
      if type(callback) == "function" then -- ref callback if exists (become a request)
        local rid = ids:gen()
        callbacks[rid] = callback
        TriggerClientEvent(iname..":tunnel_req",dest,key,args,identifier,rid)
      else -- regular trigger
        TriggerClientEvent(iname..":tunnel_req",dest,key,args,"",-1)
      end
    end
  end

  itable[key] = fcall -- add generated call to table (optimization)
  return fcall
end

-- bind an interface (listen to net requests)
-- name: interface name
-- interface: table containing functions
function Tunnel.bindInterface(name,interface)
  -- receive request
  RegisterServerEvent(name..":tunnel_req")
  AddEventHandler(name..":tunnel_req",function(member,args,identifier,rid)
    local source = source
    local delayed = false

    if Debug.active then
      Debug.pbegin("tunnelreq#"..rid.."_"..name..":"..member.." "..json.encode(Debug.safeTableCopy(args)))
    end

    local f = interface[member]

    local rets = {}
    if type(f) == "function" then
      -- bind the global function to delay the return values using the returned function with args
      TUNNEL_DELAYED = function()
        delayed = true
        return function(rets)
          rets = rets or {}

          if rid >= 0 then
            TriggerClientEvent(name..":"..identifier..":tunnel_res",source,rid,rets)
          end
        end
      end

      rets = {f(table.unpack(args))} -- call function 
      -- CancelEvent() -- cancel event doesn't seem to cancel the event for the other handlers, but if it does, uncomment this
    end

    -- send response (even if the function doesn't exist)
    if not delayed and rid >= 0 then
      TriggerClientEvent(name..":"..identifier..":tunnel_res",source,rid,rets)
    end

    if Debug.active then
      Debug.pend()
    end
  end)
end

-- get a tunnel interface to send requests 
-- name: interface name
-- identifier: unique string to identify this tunnel interface access (the name of the current resource should be fine)
function Tunnel.getInterface(name,identifier)
  local ids = Tools.newIDGenerator()
  local callbacks = {}

  -- build interface
  local r = setmetatable({},{ __index = tunnel_resolve, name = name, tunnel_ids = ids, tunnel_callbacks = callbacks, identifier = identifier })

  -- receive response
  RegisterServerEvent(name..":"..identifier..":tunnel_res")
  AddEventHandler(name..":"..identifier..":tunnel_res",function(rid,args)
    if Debug.active then
      Debug.pbegin("tunnelres#"..rid.."_"..name.." "..json.encode(Debug.safeTableCopy(args)))
    end

    local callback = callbacks[rid]
    if callback ~= nil then
      -- free request id
      ids:free(rid)
      callbacks[rid] = nil

      -- call
      callback(table.unpack(args))
    end

    Debug.pend()
  end)

  return r
end

return Tunnel
