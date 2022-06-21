-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.admin then return end

local Admin = class("Admin", vRP.Extension)

-- METHODS

function Admin:__construct()
  vRP.Extension.__construct(self)

  self.noclip = false
  self.spectate = false
  self.lastCoord = nil
  self.noclipEntity = nil
  self.noclip_speed = 1.0

  -- noclip task
  Citizen.CreateThread(function()
    local Base = vRP.EXT.Base

    while true do
      Citizen.Wait(0)
      if self.noclip then
        local ped = GetPlayerPed(-1)
        local x,y,z = Base:getPosition(self.noclipEntity)
        local dx,dy,dz = Base:getCamDirection(self.noclipEntity)
        local speed = self.noclip_speed

        -- reset velocity
        SetEntityVelocity(self.noclipEntity, 0.0001, 0.0001, 0.0001)
		
		if not self.spectate then
			-- forward
			if IsControlPressed(0,32) then -- MOVE UP
			  x = x+speed*dx
			  y = y+speed*dy
			  z = z+speed*dz
			end

			-- backward
			if IsControlPressed(0,269) then -- MOVE DOWN
			  x = x-speed*dx
			  y = y-speed*dy
			  z = z-speed*dz
			end
		end
        SetEntityCoordsNoOffset(self.noclipEntity,x,y,z,true,true,true)
      end
    end
  end)
end

function Admin:toggleNoclip()
  self.noclip = not self.noclip

  local ped = GetPlayerPed(-1)
  
  if IsPedInAnyVehicle(ped, false) then
      self.noclipEntity = GetVehiclePedIsIn(ped, false)
  else
      self.noclipEntity = ped
  end
  
  SetEntityCollision(self.noclipEntity, not self.noclip, not self.noclip)
  SetEntityInvincible(self.noclipEntity, self.noclip)
  SetEntityVisible(self.noclipEntity, not self.noclip, false)
  
  -- rotate entity
  vx,vy,vz = GetGameplayCamRot(2)
  SetEntityRotation(self.noclipEntity, vx, nil, nil, 0, false)
end

function Admin:toggleSpectate(target)
  self.spectate = not self.spectate
	
  local ped = GetPlayerPed(-1)
  
  if IsPedAPlayer(target) then
	self.target = player
  else
	for _,ai in ipairs(GetGamePool('CPed')) do
		if ai == tonumber(target) then self.target = ai end
	end
  end

  NetworkSetInSpectatorMode(self.spectate, self.target)
end

-- ref: https://github.com/citizenfx/project-lambdamenu/blob/master/LambdaMenu/teleportation.cpp#L301
function Admin:teleportToMarker()
  local ped = GetPlayerPed(-1)

  -- find GPS blip

  local it = GetBlipInfoIdIterator()
  local blip = GetFirstBlipInfoId(it)
  local ok, done
  repeat
    ok = DoesBlipExist(blip)
    if ok then
      if GetBlipInfoIdType(blip) == 4 then
        ok = false
        done = true
      else
        blip = GetNextBlipInfoId(it)
      end
    end
  until not ok

  if done then
    local x,y = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())) -- GetBlipInfoIdCoord fix

    local gz, ground = 0, false
    for z=0,800,50 do
      SetEntityCoordsNoOffset(ped, x+0.001, y+0.001, z+0.001, 0, 0, 1);
      ground, gz = GetGroundZFor_3dCoord(x,y,z+0.001)
      if ground then break end
    end

    if ground then
      vRP.EXT.Base:teleport(x,y,gz+3)
    else
      vRP.EXT.Base:teleport(x,y,1000)
      GiveDelayedWeaponToPed(ped, 0xFBAB5776, 1, 0)
    end
  end
end

-- TUNNEL

Admin.tunnel = {}
Admin.tunnel.toggleNoclip = Admin.toggleNoclip
Admin.tunnel.toggleSpectate = Admin.toggleSpectate
Admin.tunnel.teleportToMarker = Admin.teleportToMarker

vRP:registerExtension(Admin)
