
local cfg = {}

-- define static transformers
-- see https://github.com/ImagicTheCat/vRP modules documentation to understand the transformer concept/definition

cfg.transformers = {
  {
    -- example transformers
    title="Body training", -- menu name
    color={255,125,0}, -- color
    max_units=1000,
    units_per_minute=1000,
    position={-1202.96252441406,-1566.14086914063,4.61040639877319},
    radius=7.5, height=1.5, -- area
    recipes = {
      ["Strength"] = { -- action name
        description="Increase your strength.", -- action description
        reagents={}, 
        products={
          aptitudes={ 
            ["physical.strength"] = 1 -- "group.aptitude", give 1 exp per unit
          }
        },
      }
    }
  },
  {
    title="Peaches",
    color={255,125,24},
    max_units=10,
    units_per_minute=1,
    position={-2141.46630859375,-79.5226974487305,53.7380447387695},
    radius=15, height=4,
    recipes = {
      ["Harvest"] = {
        description="Harvest peaches.",
        reagents={},
        products={
          items = {
            ["edible|peach"] = 3
          }
        }
      }
    }
  },
  {
    title="Peaches",
    color={255,125,24},
    max_units=10,
    units_per_minute=1,
    position={-2185.3857421875,-43.3630828857422,74.495719909668},
    radius=15, height=4,
    recipes = {
      ["Harvest"] = {
        description="Harvest peaches.",
        reagents = {},
        products={
          items = {
            ["edible|peach"] = 3
          }
        }
      }
    }
  },
  {
    title="Peaches",
    color={255,125,24},
    max_units=10,
    units_per_minute=1,
    position={-2217.4716796875,33.9435615539551,111.254753112793},
    radius=15, height=4,
    recipes = {
      ["Harvest"] = {
        description="Harvest peaches.",
        reagents={},
        products={
          items = {
            ["edible|peach"] = 3
          }
        }
      }
    }
  },
  {
    title="Peaches resale",
    color={255,125,24},
    max_units=1000,
    units_per_minute=1000,
    position={-1484.080078125,-397.131927490234,38.3666610717773},
    radius=5, height=2.5,
    recipes = {
      ["Sell"] = {
        description="Sell peaches. 25$ per 5.",
        reagents={
          items = {
            ["edible|peach"] = 5
          }
        },
        products={
          money = 25
        }
      }
    }
  },
  {
    title="Gold deposit",
    color={255,255,0},
    max_units=1000,
    units_per_minute=5,
    position={123.05940246582,3336.2939453125,30.7280216217041},
    radius=30, height=8,
    recipes = { 
      ["Search"] = {
        description="Search for gold.",
        reagents={},
        products={
          items = {
            ["gold_ore"] = 1
          }
        }
      }
    }
  },
  {
    title="Gold processing",
    color={255,255,0},
    max_units=1000,
    units_per_minute=1000,
    position={-75.9527359008789,6495.42919921875,31.4908847808838},
    radius=24, height=2,
    recipes = {
      ["Process ore"] = {
        description="Process gold ore.",
        reagents={
          items = {
            ["gold_ore"] = 1
          }
        },
        products={
          items = {
            ["gold_processed"] = 1
          }
        }
      }
    }
  },
  {
    title="Gold refinement",
    color={255,255,0},
    max_units=1000,
    units_per_minute=1000,
    position={1032.71105957031,2516.86010742188,46.6488876342773},
    radius=24,height=4,
    recipes = {
      ["Refine"] = {
        description="Transform 10 processed gold into a gold ingot using a gold catalyst.",
        reagents={
          items = {
            ["gold_processed"] = 10,
            ["gold_catalyst"] = 1
          }
        },
        products={
          items = {
            ["gold_ingot"] = 1
          }
        },
      }
    }
  },
  {
    title="Gold resale",
    color={255,255,0},
    max_units=1000,
    units_per_minute=1000,
    position={-139.963653564453,-823.515258789063,31.4466247558594}, 
    radius=8,height=1.5,
    recipes = {
      ["Sell gold"] = {
        description="Sell gold ingots, 1000$ per ingot.",
        reagents={
          items = {
            ["gold_ingot"] = 1
          }
        },
        products={
          money = 2000
        }
      }
    }
  }
}

return cfg
