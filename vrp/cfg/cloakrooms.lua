
-- this file configure the cloakrooms on the map

local cfg = {}

-- cloakroom types (_config, map of name => customization)
cfg.cloakroom_types = {
  ["police"] = {
    _config = { permission = "police.cloakroom" },
    ["Uniform"] = {
      [3] = {30,0},
      [4] = {25,2},
      [6] = {24,0},
      [8] = {58,0},
      [11] = {55,0},
      ["p2"] = {2,0}
    }
  }
}

cfg.cloakrooms = {
  {"police", 1848.21, 3688.51, 34.2671}
}

return cfg
