-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.control then return end

local Control = class("Control", vRP.Extension)

-- menu: time
local function menu_control_time(self)
 
  local function m_time(menu)
	-- Gets current system time of user
	if tonumber(os.date("%H")) >= 12 then ending = "pm" else ending = "am" end
	
	if self.cfg.clock then
		vRP.EXT.Base.remote._notify(menu.user.source, 'Time is ~y~'..tonumber(os.date("%I"))..':'..tonumber(os.date("%M"))..' '..ending)
	else
		vRP.EXT.Base.remote._notify(menu.user.source, 'Time is ~y~'..tonumber(os.date("%H"))..':'..tonumber(os.date("%M")))
	end
  end
  
  local function m_update(menu) vRP:triggerEvent("update") end
  
  -- toggles freeze time
  local function m_freeze(menu) vRP:triggerEvent("toggleFreeze") end
  
  local function m_setTime(menu, k) vRP:triggerEvent("setTime", k) end
  
	
  vRP.EXT.GUI:registerMenuBuilder("control.time", function(menu)
    local user = menu.user

    menu.title = "Time"
	menu.css.header_color = "rgba(200,0,0,0.75)"
	
	menu:addOption("Your Current Time", m_time, "Get your current time")
	
	menu:addOption("Update Time", m_update)
	menu:addOption("Freeze Time", m_freeze, "Freeze at current time")
	
	for i=1,#self.times do
		local k = self.times[i][1]	--time of days name
		menu:addOption(""..k.."", m_setTime, nil, k)
	end
  end)
end

-- menu: admin user user
local function menu_control_weather_types(self)
  
  local function m_types(menu, v)
	if not self.blackout then
		self.current = v
	
		vRP:triggerEvent("update")
	else
		vRP.EXT.Base.remote._notify(menu.user.source, 'Blackout is ~b~enabled.~y~ disable before weather change~s~..')
	end
  end

  vRP.EXT.GUI:registerMenuBuilder("control.weather.types", function(menu)
    local user = menu.user

    menu.title = "Weather Types"
    menu.css.header_color = "rgba(200,0,0,0.75)"

	for _,v in pairs(self.cfg.types) do
		menu:addOption(v, m_types, nil, v)
	end
  end)
end

-- menu: weather
local function menu_control_weather(self)
  
  local function m_update(menu)
    vRP:triggerEvent("update")
  end
  
  local function m_dyamic(menu)
    -- toggles Dynamic weather
	vRP:triggerEvent("toggleDynamic")
  end
  
  local function m_get(menu) menu.user:openMenu("control.weather.types") end
  
  local function m_set(menu)
	local user = menu.user
    local weatherType = user:prompt("Weather types: Not case Sensitive", "")
	
	vRP:triggerEvent("setWeather", weatherType)
  end
  
  local function m_blackout(menu) vRP:triggerEvent("toggleBlackout") end
  
  vRP.EXT.GUI:registerMenuBuilder("control.weather", function(menu)
    local user = menu.user

    menu.title = "Weather"
	menu.css.header_color = "rgba(200,0,0,0.75)"
	
	menu:addOption("Update Weather", m_update)
	menu:addOption("Dynamic Weather", m_dyamic, "toggles dynamic weather")
	
	menu:addOption("Set Weather", m_set, "Manually set Weather Type")
	menu:addOption("Weather types", m_get, "list of Weather Type")
	
	menu:addOption("Blackout", m_blackout, "turns off all artificial light sources in the map: buildings, street lights, etc.")
  end)
end

-- menu: admin
local function menu_control(self)

  local function m_weather(menu)
    menu.user:openMenu("control.weather")
  end
  
  local function m_time(menu)
    menu.user:openMenu("control.time")
  end


  vRP.EXT.GUI:registerMenuBuilder("control", function(menu)
    local user = menu.user

    menu.title = "Control"
    menu.css.header_color = "rgba(200,0,0,0.75)"

    menu:addOption("Weather control", m_weather, "Change server weather")
	menu:addOption("Time control", m_time, "Change server Time")
  end)
end

function Control:__construct()
	vRP.Extension.__construct(self)
	
	self.cfg = module("vrp", "cfg/control")
	
	--default weather condition
	self.current = "EXTRASUNNY"
	
	self.time 		= 0
	self.offset 	= 0
	self.timer 		= 0
	self.newTimer 	= 10
	
	self.freeze 	= false
	self.blackout 	= false
	self.dynamic 	= true	--Set to false and weather will change automatically every 10 minutes.
	
	self.types = {}
	self.times = {}
	
	--menu
	menu_control(self)
	menu_control_weather(self)
	menu_control_weather_types(self)
	menu_control_time(self)
	
	-- main menu
	vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
		menu:addOption("Control", function(menu)
			menu.user:openMenu("control")
		end)
	end)
	
	-- adds all weather types to self.types excluding hollidays
	for _,v in pairs(self.cfg.types) do table.insert(self.types, v) end
	
	-- adds all times to self.times
	for k,v in pairs(self.cfg.time) do table.insert(self.times, {k, v}) end
	
	-- sorts self.times by value 
	table.sort(self.times, function (a, b) return a[2] < b[2] end)
  
	-- adds hollidays to weather types
	if self.cfg.holiday then
		for _,v in pairs(self.cfg.holidays) do
			table.insert(self.types, v)	
		end
	end
	
	-- randomyly sets weather condions
	if not self.dynamic then
		local new = self:randomizer()
		local getNew = self:randomizer()
		if new ~= self.current then
			self.current = choice
		else
			self.current = getNew
		end	
		vRP:triggerEvent("update")
	end
	
	-- Registers a commands.
	RegisterCommand("setWeather", function(source, args, rawCommand)
		vRP:triggerEvent("setWeather", args[1])
	end, false)
	
	RegisterCommand("setTime", function(source, args, rawCommand)
		vRP:triggerEvent("setTime", args[1])
	end, false)
	
	RegisterCommand("freezeTime", function(source, args, rawCommand)
		vRP:triggerEvent("toggleFreeze")
	end, false)
	
	RegisterCommand("blackout", function(source, args, rawCommand)
		vRP:triggerEvent("toggleBlackout")
	end, false)
	
	RegisterCommand("dynamic", function(source, args, rawCommand)
		vRP:triggerEvent("toggleDynamic")
	end, false)
end

-- randomly selects weather from self.types
function Control:randomizer()
	local choice = "F"
	local n = 0
	for i, o in pairs(self.types) do
		n = n + 1
		if math.random() < (1/n) then
			choice = o      
		end
	end
	return choice
end

Control.event = {}
Control.tunnel = {}

function Control.event:update()
	for id, user in pairs(vRP.users) do
		if user:hasPermission("player.noclip") then
			self.remote._update(user.source, self.time, self.offset, self.freeze, self.current, self.blackout)
		end
    end
end

function Control.event:setWeather(name)
	local user = vRP.users_by_source[source]
	local types = self.types
	
	for types in string.gmatch(string.upper(name),"[^%s]+") do
		if self.dynamic then
			self.current = types
			vRP:triggerEvent("update")
		else
			vRP.EXT.Base.remote._notify(source, '~b~Disabled~s~ Dynamic before changing the weather.')
		end
	end
end

function Control.event:setTime(name)
	local user = vRP.users_by_source[source]
	if not self.freeze then
		for i=1,#self.times do
			local k = self.times[i][1] 	local v = self.times[i][2]
			if string.upper(name) == string.upper(k) then
				self.offset = self.offset - ( ( ((self.time + self.offset) / 60) % 24 ) - v ) * 60
			end
		end
		vRP:triggerEvent("update")
	else
		vRP.EXT.Base.remote._notify(user.source, '~b~Disabled~s~ time freeze before changing the time.')
	end
end

function Control.event:toggleBlackout()
	local user = vRP.users_by_source[source]
	self.blackout = not self.blackout
	if self.blackout then
		vRP.EXT.Base.remote._notify(user.source, 'Blackout is now ~r~enabled~s~.')
	else
		vRP.EXT.Base.remote._notify(user.source, 'Blackout is now ~b~disabled~s~.')
	end
	vRP:triggerEvent("update")
end

function Control.event:toggleFreeze()
	for id, user in pairs(vRP.users) do
		self.freeze = not self.freeze
		if self.freeze then
			local newTime = os.time(os.date("!*t"))/2 + 360
			self.offset = self.offset + self.time - newTime
			vRP.EXT.Base.remote._notify(user.source, 'Time is now ~b~frozen~s~.')
		else
			vRP.EXT.Base.remote._notify(user.source, 'Time is ~y~no longer frozen~s~.')
		end
		vRP:triggerEvent("update")
    end
end

function Control.event:toggleDynamic()
	for id, user in pairs(vRP.users) do
		self.dynamic = not self.dynamic
		if self.dynamic then
			vRP.EXT.Base.remote._notify(source, 'Dynamic weather is now ~r~enabled~s~.')
		else
			vRP.EXT.Base.remote._notify(source, 'Dynamic weather is now ~b~disabled~s~.')
		end
		vRP:triggerEvent("update")
    end
end

function Control.tunnel:update()
	self.blackout = not self.blackout
	vRP:triggerEvent("update")
end

vRP:registerExtension(Control)