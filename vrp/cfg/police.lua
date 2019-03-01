
local cfg = {}

-- {ent,cfg} will fill cfg.pos, cfg.title
cfg.pc_map_entity = {"PoI", {marker_id = 1}}

-- PCs positions
cfg.pcs = {
  {437.14007568359,-996.31872558594,30.689586639404},
  {441.97839355469,-978.94622802734,30.689605712891},
  {459.74328613281,-988.95098876953,24.914869308472}
}

-- vehicle tracking configuration
cfg.trackveh = {
  min_time = 300, -- min time in seconds
  max_time = 600, -- max time in seconds
  service = "police" -- service to alert when the tracking is successful
}

-- wanted display
-- map_entity: {ent,cfg} will fill cfg.player (server id), cfg.title
cfg.wanted = {
  map_entity = {"PlayerMark", {blip_id = 458, blip_color = 38}},
  service = "police"
}

-- illegal items (seize)
-- specify list of "idname" or "*idname" to seize all parametric items
cfg.seizable_items = {
  "dirty_money",
  "weed",
  "*wbody",
  "*wammo"
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
  ["Insult"] = 100,
  ["Speeding"] = 250,
  ["Stealing"] = 1000,
  ["Organized crime (low)"] = 10000,
  ["Organized crime (medium)"] = 25000,
  ["Organized crime (high)"] = 50000
}

return cfg
