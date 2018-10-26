
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
  ["weed"] = {"Weed", "Some weed.", nil, 0.01}
}

return cfg
