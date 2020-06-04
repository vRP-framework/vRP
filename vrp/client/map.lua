-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.map then return end

-- BLIPS: see https://wiki.gtanet.work/index.php?title=Blips for blip id/color

local IDManager = module("vrp", "lib/IDManager")

local Map = class("Map", vRP.Extension)

-- SUBCLASS

Map.Entity = class("Map.Entity")

-- Entity.command for command methods

function Map.Entity:__construct(id,cfg)
  self.id = id
  self.cfg = cfg
end

-- called when the entity is loaded
function Map.Entity:load()
end

-- called when the entity is unloaded
function Map.Entity:unload()
end

-- called to check if the entity is active
-- px, py, pz: player position
-- should return true if active
function Map.Entity:active(px, py, pz)
  return false
end

-- called at each render frame if the entity is active
-- time: seconds since last frame
function Map.Entity:frame(time) 
end


-- basic entities

local PosEntity = class("PosEntity", Map.Entity)
Map.PosEntity = PosEntity

function PosEntity:load()
  self.active_distance = self.cfg.active_distance or 250
  self.pos = self.cfg.pos
end

function PosEntity:active(px,py,pz)
  local dist = GetDistanceBetweenCoords(self.pos[1],self.pos[2],self.pos[3],px,py,pz,true)
  return (dist <= self.active_distance)
end

-- PoI
local PoI = class("PoI", Map.PosEntity)

function PoI:load()
  PosEntity.load(self)

  -- blip
  if self.cfg.blip_id and self.cfg.blip_color then
    self.blip = AddBlipForCoord(self.cfg.pos[1],self.cfg.pos[2],self.cfg.pos[3])
    SetBlipSprite(self.blip, self.cfg.blip_id)
    SetBlipAsShortRange(self.blip, true)
    SetBlipColour(self.blip, self.cfg.blip_color)

    if self.cfg.blip_scale then
      SetBlipScale(self.blip, self.cfg.blip_scale)
    end

    if self.cfg.blip_flashes then
      if self.cfg.blip_flashes == 2 then
        SetBlipFlashesAlternate(self.blip, true)
      else
        SetBlipFlashes(self.blip, true)
      end
    end

    if self.cfg.title then
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(self.cfg.title)
      EndTextCommandSetBlipName(self.blip)
    end
  end

  -- prepare marker
  self.scale = self.cfg.scale or {0.7,0.7,0.5}
  self.color = self.cfg.color or {0,255,125,125}
  self.marker_id = self.cfg.marker_id
  self.height = self.cfg.height or 0
  self.rotate_speed = self.cfg.rotate_speed
  self.rz = 0
end

function PoI:unload()
  if self.blip then
    RemoveBlip(self.blip)
  end
end

function PoI:active(px,py,pz)
  return (PosEntity.active(self, px,py,pz) and self.marker_id)
end

function PoI:frame(time)
  if self.rotate_speed then
    self.rz = (self.rz+360*self.rotate_speed*time)%360
  end

  DrawMarker(self.marker_id,self.pos[1],self.pos[2],self.pos[3]+self.height,0,0,0,0,0,self.rz,self.scale[1],self.scale[2],self.scale[3],self.color[1],self.color[2],self.color[3],self.color[4],0)
end

PoI.command = {}

function PoI.command:setBlipRoute()
  if self.blip then
    SetBlipRoute(self.blip,true)
  end
end

-- PlayerMark
local PlayerMark = class("PlayerMark", Map.Entity)

function PlayerMark:setup()
  -- get target ped
  local player = GetPlayerFromServerId(self.cfg.player)
  if player and NetworkIsPlayerConnected(player) then
    self.ped = GetPlayerPed(player)
  end

  -- blip
  if self.ped and self.cfg.blip_id and self.cfg.blip_color then
    self.blip = AddBlipForEntity(self.ped)
    SetBlipSprite(self.blip, self.cfg.blip_id)
    SetBlipAsShortRange(self.blip, true)
    SetBlipColour(self.blip, self.cfg.blip_color)

    if self.cfg.blip_scale then
      SetBlipScale(self.blip, self.cfg.blip_scale)
    end

    if self.cfg.blip_flashes then
      if self.cfg.blip_flashes == 2 then
        SetBlipFlashesAlternate(self.blip, true)
      else
        SetBlipFlashes(self.blip, true)
      end
    end

    if self.cfg.title then
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(self.cfg.title)
      EndTextCommandSetBlipName(self.blip)
    end
  end
end

function PlayerMark:load()
  self:setup()
end

function PlayerMark:unload()
  if self.blip then
    RemoveBlip(self.blip)
  end
end

function PlayerMark:active()
  if not DoesBlipExist(self.blip) then
    self:setup()
  end

  return false
end

-- METHODS

function Map:__construct()
  vRP.Extension.__construct(self)

  self.entities = {} -- map of id (number or name) => entity
  self.entities_ids = IDManager()
  self.def_entities = {} -- defined entities
  self.frame_entities = {} -- active entities for the next frames

  self.areas = {}

  -- basic entities
  self:registerEntity(PoI)
  self:registerEntity(PlayerMark)

  -- task: entities active check
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(100)

      local px,py,pz = vRP.EXT.Base:getPosition()
      self.frame_entities = {}

      for id,entity in pairs(self.entities) do
        if entity:active(px,py,pz) then
          self.frame_entities[entity] = true
        end
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

      for entity in pairs(self.frame_entities) do
        entity:frame(elapsed)
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

-- ent: Map.Entity class
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

-- add entity
-- ent: registered entity name
-- cfg: entity config
-- return id (number) or nil on failure
function Map:addEntity(ent, cfg)
  local cent = self.def_entities[ent]

  local id

  if cent then
    id = self.entities_ids:gen()
    local nent = cent(id, cfg)
    self.entities[id] = nent
    nent:load()
  end

  return id
end

-- id: number or string
function Map:removeEntity(id)
  local ent = self.entities[id]
  if ent then
    ent:unload()
    self.frame_entities[ent] = nil
    self.entities[id] = nil

    if type(id) == "number" then
      self.entities_ids:free(id)
    end
  end
end

-- id: number (update added entity) or string (create/update named entity)
-- ent: registered entity name
-- cfg: entity config
function Map:setEntity(id, ent, cfg)
  local cent = self.def_entities[ent]
  if cent then
    -- unload previous entity
    local pent = self.entities[id]
    if pent then
      pent:unload()
      self.frame_entities[pent] = nil
    end

    -- load new entity
    local nent = cent(id, cfg)
    self.entities[id] = nent
    nent:load()
  end
end

-- entity command
-- id: number or string
-- command: command name
-- ...: arguments
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

-- TUNNEL

Map.tunnel = {}

Map.tunnel.addEntity = Map.addEntity
Map.tunnel.setEntity = Map.setEntity
Map.tunnel.removeEntity = Map.removeEntity
Map.tunnel.commandEntity = Map.commandEntity
Map.tunnel.setGPS = Map.setGPS
Map.tunnel.setArea = Map.setArea
Map.tunnel.removeArea = Map.removeArea
Map.tunnel.setStateOfClosestDoor = Map.setStateOfClosestDoor

vRP:registerExtension(Map)
