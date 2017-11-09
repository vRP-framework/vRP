
local cfg = {}

-- PC position
cfg.pcs = {
  {441.595916748047,-978.925598144531,30.6896076202393}
}

-- vehicle tracking configuration
cfg.trackveh = {
  min_time = 300, -- min time in seconds
  max_time = 600, -- max time in seconds
  service = "police" -- service to alert when the tracking is successful
}

-- wanted display
cfg.wanted = {
  blipid = 458,
  blipcolor = 38,
  service = "police"
}

-- illegal items (seize)
cfg.seizable_items = {
  "dirty_money"
}

-- jails {x,y,z,radius}
cfg.jails = {
  {459.485870361328,-1001.61560058594,24.914867401123,2.1},
  {459.305603027344,-997.873718261719,24.914867401123,2.1},
  {459.999938964844,-994.331298828125,24.9148578643799,1.6}
}

-- fines
-- map of name -> money
cfg.fines = {
  ["Injure"] = 100,
  ["Excès de vitesse"] = 250,
  ["Vol"] = 1000,
  ["Crime organisé (faible)"] = 10000,
  ["Crime organisé (moyen)"] = 25000,
  ["Crime organisé (fort)"] = 50000
}

return cfg
