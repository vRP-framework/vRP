-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.command then return end

local Command = class("Command", vRP.Extension)

function Command:__construct()
  vRP.Extension.__construct(self)

  local user = vRP.EXT.Group:getUsersByPermission("player.tptome")

  if user then
    RegisterCommand("marker", function(source, args, rawCommand)
	  --vRP.EXT.Admin.remote._teleportToMarker(user.source)
	end, false)

	RegisterCommand("spectate", function(source, args, rawCommand)
	  --vRP.EXT.Weather.remote._toggleSpectate(source, args[1])
	end, false)

	RegisterCommand("setWeather", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._setWeather(source, args[1])
	end, false)

	RegisterCommand("setTime", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._setTime(source, args[1])
	end, false)

	RegisterCommand("freezeTime", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._toggleFreeze(source, args[1])
	end, false)

	RegisterCommand("blackout", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._toggleBlackout(source, args[1])
	end, false)

	RegisterCommand("speedupTime", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._speedUpTime(source, args[1])
	end, false)

	RegisterCommand("slowTime", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._slowTime(source, args[1])
	end, false)
  end
end


vRP:registerExtension(Command)