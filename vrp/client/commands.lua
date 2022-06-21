-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.command then return end

local Command = class("Command", vRP.Extension)

function Command:__construct()
  vRP.Extension.__construct(self)

end

function Command:loadout(weapons)
	local hash = GetHashKey(weapons)
	GiveWeaponToPed(GetPlayerPed(-1), hash, 9999, 0, false)
	vRP.EXT.Base:notify("Loadout successful")
end

function Command:getAI(radius)
	if not radius then radius = 10 end
	
	local ai = vRP.EXT.Misc:getClosestPeds(radius)
	
	for k,v in pairs(ai) do
		if not IsPedInAnyVehicle(k) then	-- if ped isnt in a vehicle
			vRP.EXT.Base:notify('AI id: '..k)
		end
	end
end

Command.tunnel = {}
Command.tunnel.loadout = Command.loadout
Command.tunnel.getAI = Command.getAI

vRP:registerExtension(Command)