
local Tools = module("lib/Tools")
local Debug = module("lib/Debug")

-- API used in function of the side
local TriggerRemoteEvent = nil
local RegisterLocalEvent = nil
if SERVER then
  TriggerRemoteEvent = TriggerClientEvent
  RegisterLocalEvent = RegisterServerEvent
else
  TriggerRemoteEvent = TriggerServerEvent
  RegisterLocalEvent = RegisterNetEvent
end

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

  local fname = key
  local no_wait = false
  if string.sub(key,1,1) == "_" then
    fname = string.sub(key,2)
    no_wait = true
  end

  -- generate access function
  local fcall = function(...)
    local r = nil
    local profile -- debug

    local args = {...} 
    local dest = nil
    if SERVER then
      dest = args[1]
      args = {table.unpack(args, 2, table.maxn(args))}
      if dest >= 0 and not no_wait then -- return values not supported for multiple dests (-1)
        r = async()
      end
    elseif not no_wait then
      r = async()
    end

    -- get delay data
    local delay_data = nil
    if dest then delay_data = Tunnel.delays[dest] end
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
        local rid = -1
        if r then
          rid = ids:gen()
          callbacks[rid] = r

          if Debug.active then -- debug
            profile = Debug.pbegin("tunnel_"..iname..":"..identifier.."("..rid.."):"..fname)
          end
        end

        if SERVER then
          TriggerRemoteEvent(iname..":tunnel_req",dest,fname,args,identifier,rid)
        else
          TriggerRemoteEvent(iname..":tunnel_req",fname,args,identifier,rid)
        end
      end)
    else -- no delay
      -- send request
      local rid = -1
      if r then
        rid = ids:gen()
        callbacks[rid] = r

        if Debug.active then -- debug
          profile = Debug.pbegin("tunnel_"..iname..":"..identifier.."("..rid.."):"..fname)
        end
      end

      if SERVER then
        TriggerRemoteEvent(iname..":tunnel_req",dest,fname,args,identifier,rid)
      else
        TriggerRemoteEvent(iname..":tunnel_req",fname,args,identifier,rid)
      end
    end

    if r then
      if profile then -- debug
        local rets = {r:wait()}
        Debug.pend(profile)
        return table.unpack(rets, 1, table.maxn(rets))
      else
        return r:wait()
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
  RegisterLocalEvent(name..":tunnel_req")
  AddEventHandler(name..":tunnel_req",function(member,args,identifier,rid)
    local source = source

    if Debug.active then
      Debug.log("tunnelreq#"..rid.."_"..name..":"..member.." "..json.encode(Debug.safeTableCopy(args)))
    end

    local f = interface[member]

    local rets = {}
    if type(f) == "function" then -- call bound function
      rets = {f(table.unpack(args, 1, table.maxn(args)))}
      -- CancelEvent() -- cancel event doesn't seem to cancel the event for the other handlers, but if it does, uncomment this
    end

    -- send response (even if the function doesn't exist)
    if rid >= 0 then
      if SERVER then
        TriggerRemoteEvent(name..":"..identifier..":tunnel_res",source,rid,rets)
      else
        TriggerRemoteEvent(name..":"..identifier..":tunnel_res",rid,rets)
      end
    end
  end)
end

-- get a tunnel interface to send requests 
-- name: interface name
-- identifier: unique string to identify this tunnel interface access (if nil, will be the name of the resource)
function Tunnel.getInterface(name,identifier)
  if not identifier then identifier = GetCurrentResourceName() end
  
  local ids = Tools.newIDGenerator()
  local callbacks = {}

  -- build interface
  local r = setmetatable({},{ __index = tunnel_resolve, name = name, tunnel_ids = ids, tunnel_callbacks = callbacks, identifier = identifier })

  -- receive response
  RegisterLocalEvent(name..":"..identifier..":tunnel_res")
  AddEventHandler(name..":"..identifier..":tunnel_res",function(rid,args)
--    if Debug.active then
--      Debug.log("tunnelres#"..rid.."_"..name.." "..json.encode(Debug.safeTableCopy(args)))
--    end

    local callback = callbacks[rid]
    if callback then
      -- free request id
      ids:free(rid)
      callbacks[rid] = nil

      -- call
      callback(table.unpack(args, 1, table.maxn(args)))
    end
  end)

  return r
end

return Tunnel
