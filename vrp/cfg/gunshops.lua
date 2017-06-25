
local cfg = {}
-- list of weapons for sale
-- for the native name, see https://wiki.fivem.net/wiki/Weapons (not all of them will work, look at client/player_state.lua for the real weapon list)
-- create groups like for the garage config
-- [native_weapon_name] = {display_name,body_price,ammo_price,description}
-- ammo_price can be < 1, total price will be rounded

-- _config: blipid, blipcolor, permissions (optional, only users with the permission will have access to the shop)

cfg.gunshop_types = {
  ["sandyshores1"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_BOTTLE"] = {"Bottle",1000,0,""},
    ["WEAPON_BAT"] = {"Bat",1500,0,""},
    ["WEAPON_KNUCKLE"] = {"Knuckle",1500,0,""},
    ["WEAPON_KNIFE"] = {"Knife",2000,0,""}
  },

  ["vinewood1"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_MARKSMANPISTOL"] = {"Marksman Pistol",1500,15,""},
    ["WEAPON_SNSPISTOL"] = {"Pistol",2500,15,""},
    ["WEAPON_VINTAGEPISTOL"] = {"Vintage Pistol",2500,15,""},
    ["WEAPON_PISTOL"] = {"Pistol",2500,15,""},
    ["WEAPON_COMBATPISTOL"] = {"Combat Pistol",5000,15,""},
    ["WEAPON_HEAVYPISTOL"] = {"Heavy Pistol",5000,15,""},
    ["WEAPON_HEAVYREVOLVER"] = {"Heavy Revolver",5000,15,""},
    ["WEAPON_APPISTOL"] = {"Ap Pistol",7500,15,""},
    ["WEAPON_DAGGER"] = {"Dagger",2000,0,""},
    ["WEAPON_HAMMER"] = {"Hammer",2500,0,""},
    ["WEAPON_HATCHET"] = {"Hatchet",3000,0,""}
  },

  ["vespuccibeach1"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_MICROSMG"] = {"Mini SMG",50000,25,""},
    ["WEAPON_SMG"] = {"SMG",5000,25,""},
    ["WEAPON_ASSAULTSMG"] = {"Assault SMG",5500,25,""},
    ["WEAPON_COMBATPDW"] = {"Combat PDW",7500,25,""},
    ["WEAPON_MACHINEPISTOL"] = {"Machine Pistol",7500,25,""},
    ["WEAPON_NIGHTSTICK"] = {"Nighstick",3000,0,""},
    ["WEAPON_CROWBAR"] = {"Crowwbar",3000,0,""},
    ["WEAPON_GOLFCLUB"] = {"Golf club",3500,0,""},
    ["WEAPON_SWITCHBLADE"] = {"Blade",4000,0,""},
    ["WEAPON_MACHETE"] = {"Machete",4500,0,""}
  },

  ["paletobay1"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_MARKSMANPISTOL"] = {"Marksman Pistol",1500,15,""},
    ["WEAPON_SNSPISTOL"] = {"Pistol",2500,15,""},
    ["WEAPON_COMPACTRIFLE"] = {"Mini SMG",200000,50,""},
    ["WEAPON_ASSAULTRIFLE"] = {"Assault Rifle",200000,50,""},
    ["WEAPON_CARBINERIFLE"] = {"Carabineri Rifle",200000,50,""},
    ["WEAPON_GRENADE"] = {"Grenade",500000,70,""},
    ["WEAPON_MOLOTOV"] = {"Molotv",150000,45,""},
    ["WEAPON_FLARE"] = {"Flare",200000,50,""}
  },

  ["tataviammountains1"] = {
    _config = {blipid=154,blipcolor=2},
    ["WEAPON_GUSENBERG"] = {"Gusenberg MG",200000,50,""},
    ["WEAPON_MG"] = {"MG",250000,50,""},
    ["WEAPON_COMBATMG"] = {"Combat MG",500000,70,""}
  },

  ["chumash1"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_MARKSMANPISTOL"] = {"Marksman Pistol",1500,15,""},
    ["WEAPON_SNSPISTOL"] = {"Pistol",2500,15,""},
    ["WEAPON_MARKSMANRIFLE"] = {"Marksman Rifle",150000,45,""},
    ["WEAPON_SNIPERRIFLE"] = {"Sniper Rifle",200000,50,""},
    ["WEAPON_HEAVYSNIPER"] = {"Heavy Rifle",500000,50,""}
  },

  ["eastlossantos1"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_BULLPUPRIFLE"] = {"Bullpup Rifle",200000,50,""},
    ["WEAPON_ADVANCEDRIFLE"] = {"Carabine",200000,50,""},
    ["WEAPON_SPECIALCARBINE"] = {"Special Carabine",200000,50,""},
    ["WEAPON_GRENADE"] = {"Grenade",500000,70,""},
    ["WEAPON_MOLOTOV"] = {"Molotv",150000,45,""},
    ["WEAPON_FLARE"] = {"Flare",200000,50,""}
  },

  ["midlossantosrange"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_SAWNOFFSHOTGUN"] = {"Saw Shotgun",350000,65,""},
    ["WEAPON_PUMPSHOTGUN"] = {"Pump Shotgun",500000,70,""},
    ["WEAPON_BULLPUPSHOTGUN"] = {"BullUp Shotgun",650000,72,""},
    ["WEAPON_HEAVYSHOTGUN"] = {"Heavy Shotgun",750000,75,""},
    ["WEAPON_ASSAULTSHOTGUN"] = {"Assault Shotgun",1000000,80,""}
  },

  ["greatchaparral1"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_GRENADELAUNCHER_SMOKE"] = {"Grenade Launcher",500000,100,""},
    ["WEAPON_FIREEXTINGUISHER"] = {"Fire Extinguisher",1000000,0,""},
    ["WEAPON_FIREWORK"] = {"Firework",2000000,0,""},
    ["WEAPON_SNOWBALL"] = {"SnowBall",3000000,0,""},
    ["WEAPON_FLASHLIGHT"] = {"FlashLight",50000,0,""},
    ["WEAPON_STUNGUN"] = {"Stungun",100000,0,""},
    ["WEAPON_MUSKET"] = {"Musket",150000,0,""},
    ["WEAPON_FLAREGUN"] = {"Flaregun",500000,0,""}
  },

  ["cypressflatsrange1"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_MARKSMANPISTOL"] = {"Marksman Pistol",1500,15,""},
    ["WEAPON_SNSPISTOL"] = {"Pistol",2500,15,""},
    ["WEAPON_GRENADE"] = {"Grenade",500000,70,""},
    ["WEAPON_SMOKEGRENADE"] = {"Smoke Grenade",50000,0,""},
    ["WEAPON_PETROLCAN"] = {"Petrol",50000,0,""}
  }
}

-- list of gunshops positions

cfg.gunshops = {
  {"sandyshores1", 1692.41, 3758.22, 34.7053},
  {"vinewood1", 252.696, -48.2487, 69.941},
  {"eastlossantos1", 844.299, -1033.26, 28.1949},
  {"paletobay1", -331.624, 6082.46, 31.4548},
  {"vespuccibeach1", -664.147, -935.119, 21.8292},
  {"delperro1", -1320.983, -389.260, 36.483},
  {"greatchaparral1", -1119.48803710938,2697.08666992188,18.5541591644287},
  {"tataviammountains1", 2569.62, 294.453, 108.735},
  {"chumash1", -3172.60375976563,1085.74816894531,20.8387603759766},
  {"midlossantosrange", 21.70, -1107.41, 29.79},
  {"cypressflatsrange1", 810.15, -2156.88, 29.61}
}

return cfg
