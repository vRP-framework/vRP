
local cfg = {}

cfg.inventory_weight_per_strength = 10 -- weight for an user inventory per strength level (no unit, but thinking in "kg" is a good norm)

cfg.lose_inventory_on_death = true

-- list of static chest types (map of name => {.title,.blipid,.blipcolor,.weight, .permissions (optional)})
cfg.static_chest_types = {
  ["police_seized"] = {
    title = "Seized chest",
    blipid = 374,
    blipcolor = 38,
    weight = 500,
    permissions = {"police.chest_seized"}
  }
}

-- list of static chest points
cfg.static_chests = {
  {"police_seized", 1855.13940429688,3688.68579101563,34.2670478820801}
}

return cfg
