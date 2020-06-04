-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.map then return end

local Map = class("Map", vRP.Extension)

-- SUBCLASS

Map.User = class("User")

function Map.User:__construct()
  self.map_areas = {}
end

-- create/update a player area
-- cb_enter(user, name): (optional) called when entering the area
-- cb_leave(user, name): (optional) called when leaving the area
function Map.User:setArea(name,x,y,z,radius,height,cb_enter,cb_leave)
  self:removeArea(name)
  self.map_areas[name] = {enter=cb_enter,leave=cb_leave}
  vRP.EXT.Map.remote._setArea(self.source,name,x,y,z,radius,height)
end

function Map.User:removeArea(name)
  -- delete local area
  local area = self.map_areas[name] 
  if area then
    -- delete remote area
    vRP.EXT.Map.remote._removeArea(self.source,name)

    if area.inside and area.leave then
      area.leave(self, name)
    end

    self.map_areas[name] = nil
  end
end

function Map.User:inArea(name)
  local area = self.map_areas[name]
  if area then return area.inside end
end

-- METHODS

function Map:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/map")
  self:log(#self.cfg.entities.." entities")
end

-- EVENT

Map.event = {}
function Map.event:playerLeave(user)
  -- leave areas
  for name,area in pairs(user.map_areas) do
    if area.inside and area.leave then
      area.leave(user, name)
    end
  end
end

function Map.event:playerSpawn(user, first_spawn)
  -- add additional entities
  if first_spawn then
    for _, entdef in ipairs(self.cfg.entities) do
      self.remote._addEntity(user.source, entdef[1], entdef[2])
    end
  end
end

-- TUNNEL

Map.tunnel = {}

function Map.tunnel:enterArea(name)
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    local area = user.map_areas[name] 
    if area and not area.inside then -- trigger enter callback
      area.inside = true
      if area.enter then
        area.enter(user,name)
      end
    end
  end
end

function Map.tunnel:leaveArea(name)
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    local area = user.map_areas[name] 
    if area and area.inside then -- trigger enter callback
      area.inside = false
      if area.leave then
        area.leave(user,name)
      end
    end
  end
end

vRP:registerExtension(Map)
