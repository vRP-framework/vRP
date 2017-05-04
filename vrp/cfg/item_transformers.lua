
local cfg = {}

-- define static item transformers
-- see https://github.com/ImagicTheCat/vRP to understand the item transformer concept/definition

cfg.item_transformers = {
  -- example of harvest item transformer
  {
    name="Water bottles tree", -- menu name
    r=0,g=125,b=255, -- color
    max_units=10,
    units_per_minute=5,
    x=1858,y=3687.5,z=34.26, -- pos
    radius=5, height=1.5, -- area
    action="Harvest", -- action name
    description="Harvest some water bottles.", -- action description
    in_money=0, -- money taken per unit
    out_money=0, -- money earned per unit
    reagents={}, -- items taken per unit
    products={ -- items given per unit
      ["water_bottle"] = 1
    }
  }
}

return cfg
