local cfg = {}

cfg.warp_delay = 3 -- seconds, delay before being able to trigger another warp (prevent loop)

-- default warp map entities by mode
-- map of mode => {ent,cfg} (will fill cfg.pos)
cfg.default_map_entities = {
  [0] = {"Warp", {color = {255,0,0,125}}},
  [1] = {"Warp", {color = {0,255,0,125}}},
  [2] = {"Warp", {color = {0,0,255,125}}}
}

-- list of warps {pos, target, cfg}
-- pos: {x,y,z}
-- target: {x,y,z}
-- cfg: (optional)
--- mode: (optional) integer, 0: player warp, 1: vehicle warp, 2: both (default: 0)
--- permissions: (optional)
--- map_entity: (optional) replace the default map entity
cfg.warps = {
  -- A to B
  {{-542.68975830078,-238.42790222168,36.749378204346},{-535.21960449219,-253.25895690918,35.796085357666},{mode = 0}},
  -- B to A
  {{-535.21960449219,-253.25895690918,35.796085357666},{-542.68975830078,-238.42790222168,36.749378204346},{mode = 0}},
  -- C to D (with vehicle only)
  {{-549.23883056641,-243.92469787598,36.738178253174},{-538.77911376953,-264.68148803711,35.492126464844},{mode = 1}},
  -- D to C (with vehicle only)
  {{-538.77911376953,-264.68148803711,35.492126464844},{-549.23883056641,-243.92469787598,36.738178253174},{mode = 1}}
}

return cfg
