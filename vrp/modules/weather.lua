-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.weather then return end

local Weather = class("Weather", vRP.Extension)
Weather.event = {}

local function menu_types(self)

  vRP.EXT.GUI:registerMenuBuilder("types", function(menu)
	local user = menu.user
	menu.title = "Forcast Types"
	menu.css.header_color = "rgba(200,0,0,0.75)"
	
	for _,v in pairs(self.cfg.types) do
		menu:addOption(v, function(menu)
		  self.remote._setWeather(source, v)
		end)
	end
  end)
end

local function menu_forcast(self)

  vRP.EXT.GUI:registerMenuBuilder("forcast", function(menu)
	local user = menu.user
	menu.title = "Forcast"
	menu.css.header_color = "rgba(200,0,0,0.75)"
	
	menu:addOption("Blackout", function(menu)
      self.remote._toggleBlackout(source)
    end)
	
	menu:addOption("Set Weather", function(menu)
	  local weather = user:prompt("Weather types: Not case Sensitive", "")
      self.remote._setWeather(source, string.upper(weather))
    end)
	
	menu:addOption("Types", function(menu)
      menu.user:openMenu("types")
    end)
  end)
end

local function menu_timeOfDay(self)

  vRP.EXT.GUI:registerMenuBuilder("timeOfDay", function(menu)
	local user = menu.user
	menu.title = "Time of Day"
	menu.css.header_color = "rgba(200,0,0,0.75)"
	
	for i=1, #self.times do
		local name, hour = self.times[i][1], self.times[i][2]	-- time of day name, hour
		menu:addOption(name, function(menu)
		  self.remote._setTime(source, hour)
		end)
	end
  end)
end

local function menu_time(self)

  vRP.EXT.GUI:registerMenuBuilder("time", function(menu)
	local user = menu.user
	menu.title = "Time"
	menu.css.header_color = "rgba(200,0,0,0.75)"
	
	menu:addOption("Freeze Time", function(menu)
      self.remote._toggleFreeze(source)
    end)
	
	menu:addOption("Set Time", function(menu)
	  local timeChange = user:prompt("Set Time: 24 hour format from 0 - 23", "")
      self.remote._setTime(source, timeChange)
    end)
	
	menu:addOption("Speed Up Time", function(menu)
	  local timeChange = user:prompt("Set Multiplyer: recomended 2 - 6 (1 is default speed)", "")
      self.remote._speedUpTime(source, timeChange)
    end)
	
	menu:addOption("Slow Down Time", function(menu)
	  local timeChange = user:prompt("Set Divider: recomended 2 - 6. (1 is default speed)", "")
      self.remote._slowTime(source, timeChange)
    end)
	
	menu:addOption("Time of Day", function(menu)
      menu.user:openMenu("timeOfDay")
    end)
  end)
end

local function menu_weather(self)

  vRP.EXT.GUI:registerMenuBuilder("weather", function(menu)
	local user = menu.user
	menu.title = "Weather"
	menu.css.header_color = "rgba(200,0,0,0.75)"
	
	menu:addOption("Forcast", function(menu)
      menu.user:openMenu("forcast")
    end)
	
	menu:addOption("Time", function(menu)
      menu.user:openMenu("time")
    end)
  end)
end

function Weather:__construct()
  vRP.Extension.__construct(self)
  
  self.cfg = module("vrp", "cfg/weather")
  
  self.types = {}
  self.times = {}
	
  --menu
  menu_weather(self)
  menu_forcast(self)
  menu_types(self)
  menu_time(self)
  menu_timeOfDay(self)
	
  -- main menu
  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
	menu:addOption("Weather", function(menu)
		menu.user:openMenu("weather")
	end)
  end)
  
  for _,v in pairs(self.cfg.types) do table.insert(self.types, v) end	-- adds all weather types to self.types 

  for k,v in pairs(self.cfg.time) do table.insert(self.times, {k, v}) end	-- adds all times to self.times

  table.sort(self.times, function (a, b) return a[2] < b[2] end)	-- sorts self.times by value 
  
  table.sort(self.types, function (a, b) return string.upper(a) < string.upper(b) end) 	-- sorts self.types alphabetically
end

function Weather.event:playerSpawn(user, first_spawn)
  if first_spawn then
	self.remote._sync(user.source)
  end
end

vRP:registerExtension(Weather)