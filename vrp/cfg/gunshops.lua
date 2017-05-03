
local cfg = {}

-- list of weapons for sale
-- for the native name, see https://wiki.fivem.net/wiki/Weapons (not all of them will work, look at client/player_state.lua for the real weapon list)
-- create groups like for the garage config
-- [native_weapon_name] = {display_name,body_price,ammo_price,description}
-- ammo_price can be < 1, total price will be rounded
cfg.gunshop_types = {
  ["white"] = {
    _config = {blipid=154,blipcolor=1},
    ["WEAPON_KNIFE"] = {"Knife",100,0,"A knife."},
  },
  ["handgun"] = {
    _config = {blipid=156,blipcolor=1},
    ["WEAPON_PISTOL"] = {"Pistol",750,1,"A pistol."}
  }
}

-- list of gunshops positions
-- (default list by KonScyence, https://github.com/KonScyence/FiveM-GTAV-Blips/blob/master/default-blips/blips.lua)

cfg.gunshops = {
  {"white",1701.292, 3750.450, 34.365},
  {"handgun",237.428, -43.655, 69.698},
  {"handgun",843.604, -1017.784, 27.546},
  {"handgun",-321.524, 6072.479, 31.299},
  {"handgun",-664.218, -950.097, 21.509},
  {"handgun",-1320.983, -389.260, 36.483},
  {"handgun",-1109.053, 2686.300, 18.775},
  {"handgun",2568.379, 309.629, 108.461},
  {"handgun",-3157.450, 1079.633, 20.692}
}

return cfg
