-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.weather then return end

local Weather = class("Weather", vRP.Extension)

-- METHODS

function Weather:__construct()
  vRP.Extension.__construct(self)
  
  self.current = nil
  self.freeze = false
  self.blackout = false
  
  self.time = 0
  self.newTime = 0
  self.offset = 0
  
  self.timer = 0
  self.newTimer = 10
  
  self.normal = 2000	-- normal ms per minute
  self.alteredTime = 0	-- altered ms per minute
  self.speedTime = 1	-- time speed increase default
  self.slowTime = 1		-- time speed decrease default
  
end

function Weather:sync()
	if not self.current then self.current = 'CLEAR' end
	self.remote._setWeather(self.current)
	
	if self.alteredTime >= 0 then self.alteredTime = 2000 end	-- prevents time issue
	SetMillisecondsPerGameMinute(self.alteredTime)
end

function Weather:setWeather(weather)
	local current = string.upper(weather)
	if not current then current = 'CLEAR' end
	
	self.current = current
	ClearOverrideWeather()
	ClearWeatherTypePersist()
	SetWeatherTypePersist(current)
	SetWeatherTypeNow(current)
	SetWeatherTypeNowPersist(current)
end

function Weather:setHour(hour)
    self.offset = self.offset - ((((self.time + self.offset) / 60) % 24 ) - tonumber(hour)) * 60
end

function Weather:setTime(hour)
  if not hour then hour = 12 end 
  self:setHour(hour)
  
	local newTime = self.time
	if GetGameTimer() - 500  > self.timer then
		newTime = newTime + 0.25
		self.timer = GetGameTimer()
	end
	
	self.time = newTime
	hour = math.floor(((self.time + self.offset)/60)%24)
	minute = math.floor((self.time + self.offset)%60)
	NetworkOverrideClockTime(hour, minute, 0)
end

function Weather:speedUpTime(inc)
  SetMillisecondsPerGameMinute(self.normal)
  
  if not inc then inc = self.speedTime end
  local minute = math.floor(GetMillisecondsPerGameMinute() / inc)
  
  SetMillisecondsPerGameMinute(minute)
  self.alteredTime = minute
end

function Weather:slowTime(dec)
  SetMillisecondsPerGameMinute(self.normal)
  
  if not dec then dec = self.slowTime end
  local minute = math.floor(GetMillisecondsPerGameMinute() * dec)
  
  SetMillisecondsPerGameMinute(minute)
  self.alteredTime = minute
end

function Weather:toggleFreeze()
  self.freeze = not self.freeze
  SetMillisecondsPerGameMinute(self.normal)
  local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()

  while self.freeze do
        Wait(1)
        NetworkOverrideClockTime(GetClockHours(), GetClockMinutes(), GetClockSeconds())
    end
end

function Weather:toggleBlackout()
  self.blackout = not self.blackout
  SetArtificialLightsState(self.blackout)
end

-- TUNNEL

Weather.tunnel = {}
Weather.tunnel.sync = Weather.sync
Weather.tunnel.setWeather = Weather.setWeather
Weather.tunnel.setTime = Weather.setTime
Weather.tunnel.toggleFreeze = Weather.toggleFreeze
Weather.tunnel.toggleBlackout = Weather.toggleBlackout
Weather.tunnel.speedUpTime = Weather.speedUpTime
Weather.tunnel.slowTime = Weather.slowTime

vRP:registerExtension(Weather)