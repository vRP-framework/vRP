-- BLIPS: see https://wiki.gtanet.work/index.php?title=Blips for blip id/color

local Tools = module("vrp", "lib/Tools")

local Map = class("Map", vRP.Extension)

function Map:__construct()
  vRP.Extension.__construct(self)

  self.named_blips = {}

  self.markers = {}
  self.marker_ids = Tools.newIDGenerator()
  self.named_markers = {}

  self.areas = {}

  -- markers draw loop task
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)

      local px,py,pz = vRP.EXT.Base:getPosition()

      for k,v in pairs(self.markers) do
        -- check visibility
        if GetDistanceBetweenCoords(v.x,v.y,v.z,px,py,pz,true) <= v.visible_distance then
          DrawMarker(1,v.x,v.y,v.z,0,0,0,0,0,0,v.sx,v.sy,v.sz,v.r,v.g,v.b,v.a,0,0,0,0)
        end
      end
    end
  end)

  -- areas triggers detections task
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

-- create new blip, return native id
function Map:addBlip(x,y,z,idtype,idcolor,text)
  local blip = AddBlipForCoord(x+0.001,y+0.001,z+0.001) -- solve strange gta5 madness with integer -> double
  SetBlipSprite(blip, idtype)
  SetBlipAsShortRange(blip, true)
  SetBlipColour(blip,idcolor)

  if text ~= nil then
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
  end

  return blip
end

-- remove blip by native id
function Map:removeBlip(id)
  RemoveBlip(id)
end

-- set a named blip (same as addBlip but for a unique name, add or update)
-- return native id
function Map:setNamedBlip(name,x,y,z,idtype,idcolor,text)
  self:removeNamedBlip(name) -- remove old one

  self.named_blips[name] = self:addBlip(x,y,z,idtype,idcolor,text)
  return self.named_blips[name]
end

-- remove a named blip
function Map:removeNamedBlip(name)
  if self.named_blips[name] ~= nil then
    self:removeBlip(self.named_blips[name])
    self.named_blips[name] = nil
  end
end

-- GPS

-- set the GPS destination marker coordinates
function Map:setGPS(x,y)
  SetNewWaypoint(x+0.0001,y+0.0001)
end

-- set route to native blip id
function Map:setBlipRoute(id)
  SetBlipRoute(id,true)
end

-- MARKER

-- add a circular marker to the game map
-- return marker id
function Map:addMarker(x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  local marker = {x=x,y=y,z=z,sx=sx,sy=sy,sz=sz,r=r,g=g,b=b,a=a,visible_distance=visible_distance}


  -- default values
  if marker.sx == nil then marker.sx = 2.0 end
  if marker.sy == nil then marker.sy = 2.0 end
  if marker.sz == nil then marker.sz = 0.7 end

  if marker.r == nil then marker.r = 0 end
  if marker.g == nil then marker.g = 155 end
  if marker.b == nil then marker.b = 255 end
  if marker.a == nil then marker.a = 200 end

  -- fix gta5 integer -> double issue
  marker.x = marker.x+0.001
  marker.y = marker.y+0.001
  marker.z = marker.z+0.001
  marker.sx = marker.sx+0.001
  marker.sy = marker.sy+0.001
  marker.sz = marker.sz+0.001

  if marker.visible_distance == nil then marker.visible_distance = 150 end

  local id = self.marker_ids:gen()
  self.markers[id] = marker

  return id
end

-- remove marker
function Map:removeMarker(id)
  if self.markers[id] then
    self.markers[id] = nil
    self.marker_ids:free(id)
  end
end

-- set a named marker (same as addMarker but for a unique name, add or update)
-- return id
function Map:setNamedMarker(name,x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  self:removeNamedMarker(name) -- remove old marker

  self.named_markers[name] = self:addMarker(x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  return self.named_markers[name]
end

function Map:removeNamedMarker(name)
  if self.named_markers[name] then
    self:removeMarker(self.named_markers[name])
    self.named_markers[name] = nil
  end
end

-- AREA

-- create/update a cylinder area
function Map:setArea(name,x,y,z,radius,height)
  local area = {x=x+0.001,y=y+0.001,z=z+0.001,radius=radius,height=height}

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

  SetStateOfClosestDoorOfType(hash,x,y,z,locked,doorswing+0.0001)
end

function Map:openClosestDoor(doordef)
  self:setStateOfClosestDoor(doordef, false, 0)
end

function Map:closeClosestDoor(doordef)
  self:setStateOfClosestDoor(doordef, true, 0)
end

-- TUNNEL

Map.tunnel = {}

Map.tunnel.addBlip = Map.addBlip
Map.tunnel.removeBlip = Map.removeBlip
Map.tunnel.setNamedBlip = Map.setNamedBlip
Map.tunnel.removeNamedBlip = Map.removeNamedBlip
Map.tunnel.setGPS = Map.setGPS
Map.tunnel.setBlipRoute = Map.setBlipRoute
Map.tunnel.addMarker = Map.addMarker
Map.tunnel.removeMarker = Map.removeMarker
Map.tunnel.setNamedMarker = Map.setNamedMarker
Map.tunnel.removeNamedMarker = Map.removeNamedMarker
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
