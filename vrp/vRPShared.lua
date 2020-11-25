-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

--[[
MIT License

Copyright (c) 2017 ImagicTheCat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

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
        return v(self, ...)
      end
    end

    Tunnel.bindInterface("vRP.EXT."..class.name(self), self.tunnel_interface)
  end

  if self.proxy then -- build tunnel interface
    self.proxy_interface = {}
    for k,v in pairs(self.proxy) do
      self.proxy_interface[k] = function(...)
        return v(self, ...)
      end
    end

    Proxy.addInterface("vRP.EXT."..class.name(self), self.proxy_interface)
  end

  -- tunnel remote
  self.remote = Tunnel.getInterface("vRP.EXT."..class.name(self))
end

-- level: (optional) level, 0 by default
function vRPShared.Extension:log(msg, level)
  vRP:log(msg, class.name(self), level)
end

function vRPShared.Extension:error(msg)
  vRP:error(msg, class.name(self))
end

-- METHODS

function vRPShared:__construct()
  -- extensions
  self.EXT = {} -- map of name => ext
  self.ext_listeners = {} -- map of name => map of ext => callback

  self.modules = module("vrp", "cfg/modules")

  self.log_level = 0
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

      self:log("Extension "..class.name(ext).." loaded.")

      self:triggerEvent("extensionLoad", ext)
    else
      self:error("An extension named "..class.name(extension).." is already registered.")
    end
  else
    self:error("Not an Extension class.")
  end
end

-- trigger event (with async call for each listener)
function vRPShared:triggerEvent(name, ...)
  local exts = self.ext_listeners[name]
  if exts then
    local params = table.pack(...)
    for ext,func in pairs(exts) do
      async(function()
        func(ext, table.unpack(params, 1, params.n))
      end)
    end
  end
end

-- trigger event and wait for all listeners to complete
function vRPShared:triggerEventSync(name, ...)
  local exts = self.ext_listeners[name]
  if exts then
    local params = table.pack(...)
    local count = 0
    local r = async()
    for ext, func in pairs(exts) do
      count = count+1
    end
    for ext,func in pairs(exts) do
      async(function()
        func(ext, table.unpack(params, 1, params.n))
        count = count-1
        if count == 0 then -- all done
          r()
        end
      end)
    end
    r:wait() -- wait events completion
  end
end

-- msg: log message
-- suffix: (optional) category, string
-- level: (optional) level, 0 by default
function vRPShared:log(msg, suffix, level)
  if not level then level = 0 end

  if level <= self.log_level then
    if suffix then
      print("[vRP:"..suffix.."] "..msg)
    else
      print("[vRP] "..msg)
    end
  end
end

-- msg: error message
-- suffix: optional category, string
function vRPShared:error(msg, suffix)
  if suffix then
    error("[vRP:"..suffix.."] "..msg)
  else
    error("[vRP] "..msg)
  end
end

return vRPShared
