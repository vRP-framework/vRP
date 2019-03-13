
local cfg = {}

-- define skinshop config
local cfg_clothing = {
  -- customization parts list {title, part}
  parts = {
    {"Hats", "prop:0"},
    {"Face", "drawable:1"},
    {"Ears", "prop:2"},
    {"Glasses", "prop:1"},
    {"Neck", "drawable:7"},
    {"Hand", "drawable:3"},
    {"Watches", "prop:6"},
    {"Bracelets", "prop:7"},
    {"Shirt", "drawable:8"},
    {"Jacket", "drawable:11"},
    {"Legs", "drawable:4"},
    {"Shoes", "drawable:6"}
  },
  map_entity = {"PoI", {blip_id = 73, blip_color = 3, marker_id = 1}}
}

local cfg_barber = {
  parts = {
    {"Hair", "drawable:2"},
    {"Hair color", "hair_color"},
    {"Face", "drawable:0"},
    {"Eyebrows", "overlay:2"},
    {"Facial Hair", "overlay:1"},
    {"Chest Hair", "overlay:10"},
    {"Ageing", "overlay:3"},
    {"Moles/Freckles", "overlay:9"},
    {"Blemishes", "overlay:0"},
    {"Body Blemishes", "overlay:11"},
    {"Body Blemishes+", "overlay:12"},
    {"Complexion", "overlay:6"},
    {"Blush", "overlay:5"},
    {"Lipstick", "overlay:8"},
    {"Makeup", "overlay:4"}
  },
  map_entity = {"PoI", {blip_id = 71, blip_color = 3, marker_id = 1}}
}

-- changes prices (any change to the character parts add amount to the total price)
cfg.drawable_change_price = 20
cfg.texture_change_price = 5
cfg.color_change_price = 3

-- skinshops list {cfg,x,y,z}
-- cfg: {.parts, .map_entity}
--- map_entity: {ent, cfg} will fill cfg.title and cfg.pos
cfg.skinshops = {
  {cfg_clothing,72.2545394897461,-1399.10229492188,29.3761386871338},
  {cfg_clothing,-703.77685546875,-152.258544921875,37.4151458740234},
  {cfg_clothing,-167.863754272461,-298.969482421875,39.7332878112793},
  {cfg_clothing,428.694885253906,-800.1064453125,29.4911422729492},
  {cfg_clothing,-829.413269042969,-1073.71032714844,11.3281078338623},
  {cfg_clothing,-1193.42956542969,-772.262329101563,17.3244285583496},
  {cfg_clothing,-1447.7978515625,-242.461242675781,49.8207931518555},
  {cfg_clothing,11.6323690414429,6514.224609375,31.8778476715088},
  {cfg_clothing,1696.29187011719,4829.3125,42.0631141662598},
  {cfg_clothing,123.64656829834,-219.440338134766,54.5578384399414},
  {cfg_clothing,618.093444824219,2759.62939453125,42.0881042480469},
  {cfg_clothing,1190.55017089844,2713.44189453125,38.2226257324219},
  {cfg_clothing,-3172.49682617188,1048.13330078125,20.8632030487061},
  {cfg_clothing,-1108.44177246094,2708.92358398438,19.1078643798828},

  {cfg_barber,-813.71356201172,-184.06265258789,37.56893157959},
  {cfg_barber,136.97842407227,-1707.8671875,29.291620254517},
  {cfg_barber,-1282.8363037109,-1116.9685058594,6.9901127815247},
  {cfg_barber,1931.7169189453,3730.3142089844,32.844432830811},
  {cfg_barber,1212.4298095703,-472.55453491211,66.2080078125},
  {cfg_barber,-32.703586578369,-152.55470275879,57.076503753662},
  {cfg_barber,-278.02655029297,6228.3115234375,31.695518493652}
}

return cfg
