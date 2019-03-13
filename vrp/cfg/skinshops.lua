
local cfg = {}

-- define skinshop config
local dcfg = {
  -- customization parts list {title, part}
  parts = {
    {"Hats", "prop:0"},
    {"Hair", "drawable:2"},
    {"Face", "drawable:0"},
    {"Face+", "drawable:1"},
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

-- changes prices (any change to the character parts add amount to the total price)
cfg.drawable_change_price = 20
cfg.texture_change_price = 5

-- skinshops list {cfg,x,y,z}
-- cfg: {.parts, .map_entity}
--- map_entity: {ent, cfg} will fill cfg.title and cfg.pos
cfg.skinshops = {
  {dcfg,72.2545394897461,-1399.10229492188,29.3761386871338},
  {dcfg,-703.77685546875,-152.258544921875,37.4151458740234},
  {dcfg,-167.863754272461,-298.969482421875,39.7332878112793},
  {dcfg,428.694885253906,-800.1064453125,29.4911422729492},
  {dcfg,-829.413269042969,-1073.71032714844,11.3281078338623},
  {dcfg,-1193.42956542969,-772.262329101563,17.3244285583496},
  {dcfg,-1447.7978515625,-242.461242675781,49.8207931518555},
  {dcfg,11.6323690414429,6514.224609375,31.8778476715088},
  {dcfg,1696.29187011719,4829.3125,42.0631141662598},
  {dcfg,123.64656829834,-219.440338134766,54.5578384399414},
  {dcfg,618.093444824219,2759.62939453125,42.0881042480469},
  {dcfg,1190.55017089844,2713.44189453125,38.2226257324219},
  {dcfg,-3172.49682617188,1048.13330078125,20.8632030487061},
  {dcfg,-1108.44177246094,2708.92358398438,19.1078643798828}
}

return cfg
