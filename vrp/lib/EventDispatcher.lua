-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)


-- Simple event dispatcher class
local EventDispatcher = class("EventDispatcher")

function EventDispatcher:__construct()
  self.event_listeners = {}
end

-- listen event for a specific callback
function EventDispatcher:listen(name, callback)
  local listeners = self.event_listeners[name]
  if not listeners then -- create
    listeners = {}
    self.event_listeners[name] = listeners
  end

  listeners[callback] = true
end

-- unlisten event for a specific callback
function EventDispatcher:unlisten(name, callback)
  local listeners = self.event_listeners[name]
  if not listeners then -- create
    listeners = {}
    self.event_listeners[name] = listeners
  end

  listeners[callback] = nil
end

function EventDispatcher:triggerEvent(name, ...)
  local listeners = self.event_listeners[name]
  if listeners then
    for cb in pairs(listeners) do
      cb(...)
    end
  end
end

return EventDispatcher
