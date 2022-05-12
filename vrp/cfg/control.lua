-- client-side vRP configuration
-- (loaded client-side)

local cfg = {}

cfg.clock = true		--set clock format to 12 hr
cfg.holiday = true		--allows for holliday weather halloween, xmas

cfg.time = {
	['Morning'] 	= 9, 
	['Noon'] 		= 12, 
	['Evening'] 	= 18, 
	['Night'] 		= 23
}

cfg.types = {
	'EXTRASUNNY', 
    'CLEAR',  
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT'
}

cfg.holidays = {
    'XMAS', 
	'NEUTRAL',		--makes sky green
    'HALLOWEEN'
}

cfg.blackout_types = {
	'THUNDER', 
    'SNOW', 
    'BLIZZARD',
	'NEUTRAL',
    'HALLOWEEN'
}

return cfg
