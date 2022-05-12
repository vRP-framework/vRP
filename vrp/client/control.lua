-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.control then return end

local Control = class("Control", vRP.Extension)
local cfg = module("vrp", "cfg/control")

function Control:__construct()
    vRP.Extension.__construct(self)
	
	-- load config
	--self.cfg = module("vrp", "cfg/control")
	
	--default weather condition
	self.current = "EXTRASUNNY"
	self.last = self.current
	
	self.time = 0
	self.offset = 0
	self.timer = 0
	self.newTimer = 10
	
	self.freeze = false
	self.blackout = false
	self.suggestion = false

	self.b_chance = math.random(0,5) 	-- chance for a random blackout
	self.b_timer = math.random(0,5) 	-- how long a blackout will last
	
	-- random blackouts	based off of specific weather conditions
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			for _,v in pairs(cfg.blackout_types) do
				if self.current == v then
					if self.b_chance >= 0 then
						notification(self.current)
						notification("Its a Blackout")
						self.blackout = not self.blackout
						notification('Power should be fixed in about '..self.b_timer..' Minutes.')
						Citizen.Wait(self.b_timer * 60000)
						notification("Power is back on")
						self.blackout = not self.blackout
						
						self.remote._update()
					end
				end
			end
		end
	end)
	
	Citizen.CreateThread(function()
		local hour = 0
		local minute = 0
		while true do
			Citizen.Wait(0)
			local newTime = self.time
			
			if GetGameTimer() - 500  > self.timer then
				newTime = newTime + 0.25
				self.timer = GetGameTimer()
			end
			if self.freeze then
				self.offset = self.offset + self.time - newTime	
			end
			
			self.time = newTime
			hour = math.floor(((self.time + self.offset)/60)%24)
			minute = math.floor((self.time + self.offset)%60)
			NetworkOverrideClockTime(hour, minute, 0)
		end
	end)
	
	Citizen.CreateThread(function()
		while true do
			if self.last ~= self.current then
				self.last = self.current
				SetWeatherTypeOverTime(self.current, 1.0)	-- default 15
				Citizen.Wait(1000)
			end
			Citizen.Wait(100) -- Wait 0 seconds to prevent crashing.
			SetArtificialLightsState(self.blackout)
			--SetArtificialLightsStateAffectsVehicles(self.veh_blackout)
			ClearOverrideWeather()
			ClearWeatherTypePersist()
			SetWeatherTypePersist(self.last)
			SetWeatherTypeNow(self.last)
			SetWeatherTypeNowPersist(self.last)
			
			if self.last == 'XMAS' then 
				SetForceVehicleTrails(true)
				SetForcePedFootstepsTracks(true)
			else
				SetForceVehicleTrails(false)
				SetForcePedFootstepsTracks(false)
			end
		end
	end)	
end

--Client side notification
function notification(msg)		
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(false, false)
end

function Control:time()
	notification(GetGameTimer())
end

function Control:update(base, offset, freeze, current, blackout)
  self.time 	= base
  self.offset 	= offset
  self.freeze 	= freeze
  self.current 	= current
  self.blackout = blackout
end

Control.tunnel = {}

Control.tunnel.time 			= Control.time
Control.tunnel.update 			= Control.update

vRP:registerExtension(Control)