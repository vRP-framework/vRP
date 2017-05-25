
local cfg = {}

-- define police uniform applied customization
cfg.uniform_customization = {
  [4] = {25,2},
  [6] = {24,0},
  [8] = {58,0},
  [11] = {55,0}
}

-- cloakroom position
cfg.cloakroom = {1848.21, 3688.51, 34.2671}

-- PC position
cfg.pc = {1853.21, 3689.51, 34.2671}

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

return cfg
