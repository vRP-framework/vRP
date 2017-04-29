-- BLIPS: see https://wiki.gtanet.work/index.php?title=Blips for blip id/color

-- TUNNEL CLIENT API

-- BLIP

-- create new blip, return native id
function tvRP.addBlip(x,y,z,idtype,idcolor,text)
  local blip = AddBlipForCoord(x,y,z)
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
function tvRP.removeBlip(id)
  RemoveBlip(id)
end


local named_blips = {}

-- set a named blip (same as addBlip but for a unique name, add or update)
function tvRP.setNamedBlip(name,x,y,z,idtype,idcolor,text)
  tvRP.removeNamedBlip(name) -- remove old one

  named_blips[name] = tvRP.addBlip(x,y,z,idtype,idcolor,text)
end

-- remove a named blip
function tvRP.removeNamedBlip(name)
  if named_blips[name] ~= nil then
    tvRP.removeBlip(named_blips[name])
    named_blips[name] = nil
  end
end

-- MARKER

local markers = {}
local marker_ids = Tools.newIDGenerator()
local named_markers = {}

-- add a circular marker to the game map
-- return marker id
function tvRP.addMarker(x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  local marker = {x=x,y=y,z=z,sx=sx,sy=sy,sz=sz,r=r,g=g,b=b,a=a,visible_distance=visible_distance}


  -- default values
  if marker.sx == nil then marker.sx = 2.0 end
  if marker.sy == nil then marker.sy = 2.0 end
  if marker.sz == nil then marker.sz = 0.7 end

  if marker.r == nil then marker.r = 0 end
  if marker.g == nil then marker.g = 155 end
  if marker.b == nil then marker.b = 255 end
  if marker.a == nil then marker.a = 200 end

  -- fix scale issue
  marker.sx = marker.sx+0.001
  marker.sy = marker.sy+0.001
  marker.sz = marker.sz+0.001

  if marker.visible_distance == nil then marker.visible_distance = 150 end

  local id = marker_ids:gen()
  markers[id] = marker

  return id
end

-- remove marker
function tvRP.removeMarker(id)
  if markers[id] ~= nil then
    markers[id] = nil
    marker_ids:free(id)
  end
end

-- set a named marker (same as addMarker but for a unique name, add or update)
function tvRP.setNamedMarker(name,x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
  tvRP.removeNamedMarker(name) -- remove old marker

  named_markers[name] = tvRP.addMarker(x,y,z,sx,sy,sz,r,g,b,a,visible_distance)
end

function tvRP.removeNamedMarker(name)
  if named_markers[name] ~= nil then
    tvRP.removeMarker(named_markers[name])
    named_markers[name] = nil
  end
end

-- markers draw loop
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    local px,py,pz = tvRP.getPosition()

    for k,v in pairs(markers) do
      -- check visibility
      if GetDistanceBetweenCoords(v.x,v.y,v.z,px,py,pz,true) <= v.visible_distance then
        DrawMarker(1,v.x,v.y,v.z,0,0,0,0,0,0,v.sx,v.sy,v.sz,v.r,v.g,v.b,v.a,0,0,0,0)
      end
    end
  end
end)
