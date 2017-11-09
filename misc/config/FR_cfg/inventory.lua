
local cfg = {}

cfg.inventory_weight_per_strength = 10 -- weight for an user inventory per strength level (no unit, but thinking in "kg" is a good norm)

-- default chest weight for vehicle trunks
cfg.default_vehicle_chest_weight = 50

-- define vehicle chest weight by model in lower case
cfg.vehicle_chest_weights = {
  ["benson"] = 120,
  ["trailersmall"] = 100,
  ["trailers"] = 500,
  ["tanker"] = 5000
}

return cfg
