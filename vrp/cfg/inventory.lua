
local cfg = {}

cfg.inventory_weight_per_strength = 10 -- weight for an user inventory per strength level (no unit, but thinking in "kg" is a good norm)

-- default chest weight for vehicle trunks
cfg.default_vehicle_chest_weight = 50

-- define vehicle chest weight by model in lower case
cfg.vehicle_chest_weights = {
  ["monster"] = 250
}

-- list of static chest types (map of name => {.title,.blipid,.blipcolor,.weight, .permissions (optional)})
cfg.static_chest_types = {
  ["chest"] = { -- example of a static chest
    title = "Test chest",
    blipid = 205,
    blipcolor = 5,
    weight = 100
  }
}

-- list of static chest points
cfg.static_chests = {
  {"chest", 1855.13940429688,3688.68579101563,34.2670478820801}
}

return cfg
