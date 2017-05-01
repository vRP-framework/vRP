
local cfg = {}

-- list of weapons for sale
-- for the native name, see https://wiki.fivem.net/wiki/Weapons (not all of them will work, look at client/player_state.lua for the real weapon list)
--
-- [native_weapon_name] = {display_name,body_price,ammo_price,description}
-- ammo_price can be < 1, total price will be rounded
cfg.weapons = {
  ["WEAPON_KNIFE"] = {"Knife",100,0,"A knife."},
  ["WEAPON_PISTOL"] = {"Pistol",750,1,"A pistol."}
}

-- list of gunshops positions
-- (default list by KonScyence, https://github.com/KonScyence/FiveM-GTAV-Blips/blob/master/default-blips/blips.lua)

cfg.gunshops = {
  {1701.292, 3750.450, 34.365},
  {237.428, -43.655, 69.698},
  {843.604, -1017.784, 27.546},
  {-321.524, 6072.479, 31.299},
  {-664.218, -950.097, 21.509},
  {-1320.983, -389.260, 36.483},
  {-1109.053, 2686.300, 18.775},
  {2568.379, 309.629, 108.461},
  {-3157.450, 1079.633, 20.692}
}

return cfg
