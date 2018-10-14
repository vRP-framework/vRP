
local vRPShared = class("vRPShared")

-- SUBCLASS

-- Extension class
-- define .proxy/.tunnel for proxy and tunnel interfaces
-- ex: 
-- MyExt.tunnel = {}
-- function MyExt.tunnel:add(a,b) return a+b end
-- MyExt.remote.add(1,1) => 2
--
-- .proxy will create the extension proxy with interface name "vRP.EXT.<name>"
--
-- .event properties are listener callbacks
-- ex:
-- function MyExt.event:playerJoin(...) ... end
--
-- .User: optional class inherited by User (to extend User behavior, constructor will be executed)
vRPShared.Extension = class("vRPShared.Extension")

function vRPShared.Extension:__construct()
  -- init extension tunnel and proxy
  if self.tunnel then -- build tunnel interface
    self.tunnel_interface = {}
    for k,v in pairs(self.tunnel) do
      self.tunnel_interface[k] = function(...)
        v(self, ...)
      end
    end

    Tunnel.bindInterface("vRP.EXT."..class.name(self), self.tunnel_interface)
  end

  if self.proxy then -- build tunnel interface
    self.proxy_interface = {}
    for k,v in pairs(self.proxy) do
      self.proxy_interface[k] = function(...)
        v(self, ...)
      end
    end

    Proxy.addInterface("vRP.EXT."..class.name(self), self.proxy_interface)
  end

  -- tunnel remote
  self.remote = Tunnel.getInterface("vRP.EXT."..class.name(self))
end

-- METHODS

function vRPShared:__construct()
  -- extensions
  self.EXT = {} -- map of name => ext
  self.ext_listeners = {} -- map of name => map of ext => callback
end

-- register an extension
-- extension: Extension class
function vRPShared:registerExtension(extension)
  if class.is(extension, vRPShared.Extension) then
    if not self.EXT[class.name(extension)] then
      -- instantiate
      local ext = extension()
      self.EXT[class.name(extension)] = ext

      -- bind listeners
      if extension.event then
        for name,cb in pairs(extension.event or {}) do
          local exts = self.ext_listeners[name]
          if not exts then -- create
            exts = {}
            self.ext_listeners[name] = exts
          end

          exts[ext] = cb
        end
      end

      print("[vRP] Extension "..class.name(ext).." loaded.")
    else
      error("[vRP] An extension named "..class.name(extension).." is already registered.")
    end
  else
    error("[vRP] Not an Extension class.")
  end
end

function vRPShared:triggerEvent(name, ...)
  local exts = self.ext_listeners[name]
  if exts then
    for ext,func in pairs(exts) do
      func(ext, ...)
    end
  end
end

return vRPShared
