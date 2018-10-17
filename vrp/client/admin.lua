
local Admin = class("Admin", vRP.Extension)

-- METHODS

function Admin:__construct()
  vRP.Extension.__construct(self)

  self.noclip = false
  self.noclip_speed = 1.0

  -- noclip task
  Citizen.CreateThread(function()
    local Base = vRP.EXT.Base

    while true do
      Citizen.Wait(0)
      if self.noclip then
        local ped = GetPlayerPed(-1)
        local x,y,z = Base:getPosition()
        local dx,dy,dz = Base:getCamDirection()
        local speed = self.noclip_speed

        -- reset velocity
        SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)

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

        SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
      end
    end
  end)
end

function Admin:toggleNoclip()
  self.noclip = not self.noclip

  local ped = GetPlayerPed(-1)
  if self.noclip then -- set
    SetEntityInvincible(ped, true)
    SetEntityVisible(ped, false, false)
  else -- unset
    SetEntityInvincible(ped, false)
    SetEntityVisible(ped, true, false)
  end
end

-- TUNNEL

Admin.tunnel = {}
Admin.tunnel.toggleNoclip = Admin.toggleNoclip

vRP:registerExtension(Admin)
