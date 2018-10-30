
local cfg = {}

-- (see vRP.EXT.Inventory:defineItem)
-- map of id => {name, description, menu_builder, weight}
--- name: display name, value or genfunction(args)
--- description: value or genfunction(args) (html)
--- menu_builder: (optional) genfunction(args, menu)
--- weight: (optional) value or genfunction(args)
--
-- genfunction are functions returning a correct value as: function(args, ...)
-- where args is a list of {base_idname,args...}
cfg.items = {
  ["gold_ore"] = {"Gold ore","",nil,1},
  ["gold_processed"] = {"Gold processed","",nil,1.2},
  ["gold_ingot"] = {"Gold ingot","",nil,12},
  ["gold_catalyst"] = {"Gold catalyst","Used to transform processed gold into gold ingot.",nil,0.1},
  ["weed"] = {"Weed leaf", "", nil, 0.05},
  ["weed_processed"] = {"Weed processed", "", nil, 0.1},
  ["demineralized_water"] = {"Demineralized water (1L)","",nil,1}
}

return cfg
