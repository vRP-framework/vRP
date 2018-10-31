-- BLIPS: see https://wiki.gtanet.work/index.php?title=Blips for blip id/color

local IDManager = module("vrp", "lib/IDManager")

local Map = class("Map", vRP.Extension)

-- SUBCLASS

Map.Entity = class("Map.Entity")

-- Entity.command for command methods

function Map.Entity:__construct(cfg,x,y,z,active_distance)
  self.cfg = cfg
  self.x = x
  self.y = y
  self.z = z
  self.active_distance = active_distance

  self.active = false
  self.frame_when_inactive = false
end

function Map.Entity:load()
end

function Map.Entity:unload()
end

-- time: seconds since last frame
function Map.Entity:frame(time) 
end

-- basic entities

local PoI = class("PoI", Map.Entity)

function PoI:load()
  -- blip
  self.blip = AddBlipForCoord(x,y,z)
  SetBlipSprite(self.blip, self.cfg.blip_id)
  SetBlipAsShortRange(blip, true)
  SetBlipColour(blip, self.cfg.blip_color)

  if self.cfg.title ~= nil then
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(self.cfg.title)
    EndTextCommandSetBlipName(blip)
  end

  -- marker
  self.dpos = self.cfg.dpos or {0,0,-1}
  self.scale = self.cfg.scale or {0.7,0.7,0.5}
  self.rgba = self.cfg.rgba or {0,255,125,125}
  self.marker_id = self.cfg.marker_id
end

function PoI:unload()
  RemoveBlip(self.blip)
end

function PoI:frame(time)
  if self.marker_id then
    DrawMarker(self.marker_id,self.x+self.dpos[1],self.y+self.dpos[2],self.z+self.dpos[3],0,0,0,0,0,0,self..scale[1],self.scale[2],self.scale[3],self.rgba[1],self.rgba[2],self.rgba[3],self.rgba[4],0)
  end
end

PoI.command = {}

function PoI.command:blipRoute()
  SetBlipRoute(self.blip,true)
end

-- METHODS

function Map:__construct()
  vRP.Extension.__construct(self)

  self.entities = {} -- map of id (number or name) => entity
  self.entities_ids = IDManager()

  self.areas = {}

  -- basic entities
  self:registerEntity(PoI)

  -- task: entities active check
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(40)

      local px,py,pz = vRP.EXT.Base:getPosition()

      for id,entity in pairs(self.entities) do
        entity.active = (GetDistanceBetweenCoords(entity.x,entity.y,entity.z,px,py,pz,true) <= entity.active_distance)
      end
    end
  end)

  -- task: entities frame
  Citizen.CreateThread(function()
    local last_time = GetGameTimer()

    while true do
      Citizen.Wait(0)

      local time = GetGameTimer()
      local elapsed = (last_time-time)*0.001
      last_time = time

      local px,py,pz = vRP.EXT.Base:getPosition()

      for id,entity in pairs(self.entities) do
        if entity.active or entity.frame_when_inactive then
          entity:frame(elapsed)
        end
      end
    end
  end)

  -- task: areas triggers detections
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(250)

      local px,py,pz = vRP.EXT.Base:getPosition()

      for k,v in pairs(self.areas) do
        -- detect enter/leave

        local player_in = (GetDistanceBetweenCoords(v.x,v.y,v.z,px,py,pz,true) <= v.radius and math.abs(pz-v.z) <= v.height)

        if v.player_in and not player_in then -- was in: leave
          self.remote._leaveArea(k)
        elseif not v.player_in and player_in then -- wasn't in: enter
          self.remote._enterArea(k)
        end

        v.player_in = player_in -- update area player_in
      end
    end
  end)
end

function Map:registerEntity(ent)
  if class.is(ent, Map.Entity) then
    local id = class.name(ent)
    if self.def_entities[id] then
      self:log("WARNING: re-registered entity \""..id.."\"")
    end

    self.def_entities[id] = ent
  else
    self:error("Not an Entity class.")
  end
end

-- return id (-1 if the entity is invalid)
function Map:addEntity(ent, cfg, x, y, z)
  local cent = self.def_entities[ent]

  local id = -1

  if cent then
    id = self.entities_ids:gen()
    local ent = cent(cfg, x,y,z, vRP.cfg.default_map_entity_active_distance)
    self.entities[id] = ent
    ent:load()
  end

  return id
end

function Map:removeEntity(id)
  if type(id) == "number" then
    local ent = self.entities[id]
    if ent then
      ent:unload()
      self.entities[id] = nil
    end
  end
end

function Map:setNamedEntity(name, ent, cfg, x,y,z)
  self:removeNamedEntity(name) -- remove old one

  if type(name) == "string" then
    local cent = self.def_entities[ent]
    if cent then
      local ent = cent(cfg, x,y,z, vRP.cfg.default_map_entity_active_distance)
      self.entities[name] = ent
      ent:load()
    end
  end
end

-- remove a named blip
function Map:removeNamedEntity(name)
  if type(name) == "string" then
    local ent = self.entities[name]
    if ent then
      ent:unload()
      self.entities[name] = nil
    end
  end
end

-- entity command
-- id: entity name or id
function Map:commandEntity(id, command, ...)
  local ent = self.entities[id]
  if ent then
    local f = ent.command[command]
    if f then
      return f(ent, ...)
    end
  end
end

-- GPS

-- set the GPS destination marker coordinates
function Map:setGPS(x,y)
  SetNewWaypoint(x,y)
end

-- AREA

-- create/update a cylinder area
function Map:setArea(name,x,y,z,radius,height)
  local area = {x=x,y=y,z=z,radius=radius,height=height}

  -- default values
  if area.height == nil then area.height = 6 end

  self.areas[name] = area
end

-- remove area
function Map:removeArea(name)
  self.areas[name] = nil
end

-- DOOR

-- set the closest door state
-- doordef: .model or .modelhash
-- locked: boolean
-- doorswing: -1 to 1
function Map:setStateOfClosestDoor(doordef, locked, doorswing)
  local x,y,z = vRP.EXT.Base:getPosition()
  local hash = doordef.modelhash
  if hash == nil then
    hash = GetHashKey(doordef.model)
  end

  SetStateOfClosestDoorOfType(hash,x,y,z,locked,doorswing)
end

function Map:openClosestDoor(doordef)
  self:setStateOfClosestDoor(doordef, false, 0)
end

function Map:closeClosestDoor(doordef)
  self:setStateOfClosestDoor(doordef, true, 0)
end

-- TUNNEL

Map.tunnel = {}

Map.tunnel.addEntity = Map.addEntity
Map.tunnel.removeEntity = Map.removeEntity
Map.tunnel.setNamedEntity = Map.setNamedEntity
Map.tunnel.removeNamedEntity = Map.removeNamedEntity
Map.tunnel.commandEntity = Map.commandEntity
Map.tunnel.setGPS = Map.setGPS
Map.tunnel.setArea = Map.setArea
Map.tunnel.removeArea = Map.removeArea
Map.tunnel.setStateOfClosestDoor = Map.setStateOfClosestDoor

-- batch blips/markers loading
function Map.tunnel:loadBlipsMarkers(blips, markers)
  for k,v in pairs(blips) do
    self:addBlip(v[1],v[2],v[3],v[4],v[5],v[6])
  end

  for k,v in pairs(markers) do
    self:addMarker(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
  end
end

vRP:registerExtension(Map)
