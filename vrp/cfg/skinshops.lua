
local cfg = {}

-- define customization parts
local parts = {
  ["Face"] = 0,
  ["Hair"] = 2,
  ["Hand"] = 3,
  ["Legs"] = 4,
  ["Shirt"] = 8,
  ["Shoes"] = 6,
  ["Jacket"] = 11
}

-- changes prices (any change to the character parts add amount to the total price)
cfg.drawable_change_price = 20
cfg.texture_change_price = 5


-- skinshops list {parts,x,y,z}
-- (default list by KonScyence, https://github.com/KonScyence/FiveM-GTAV-Blips/blob/master/default-blips/blips.lua)
cfg.skinshops = {
  {parts,88.291, -1391.929, 29.200},
  {parts,-718.985, -158.059, 36.996},
  {parts,-151.204, -306.837, 38.724},
  {parts,414.646, -807.452, 29.338},
  {parts,-815.193, -1083.333, 11.022},
  {parts,-1208.098, -782.020, 17.163},
  {parts,-1457.954, -229.426, 49.185},
  {parts,-2.777, 6518.491, 31.533},
  {parts,1681.586, 4820.133, 42.046},
  {parts,130.216, -202.940, 54.505},
  {parts,618.701, 2740.564, 41.905},
  {parts,1199.169, 2694.895, 37.866},
  {parts,-3164.172, 1063.927, 20.674},
  {parts,-1091.373, 2702.356, 19.422}
}

return cfg
