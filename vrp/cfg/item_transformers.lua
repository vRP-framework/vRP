
local cfg = {}

-- define static item transformers
-- see https://github.com/ImagicTheCat/vRP to understand the item transformer concept/definition

cfg.item_transformers = {
  {
    -- example transformers
    name="Body training", -- menu name
    r=255,g=125,b=0, -- color
    max_units=1000,
    units_per_minute=1000,
    x=-1202.96252441406,y=-1566.14086914063,z=4.61040639877319,
    radius=7.5, height=1.5, -- area
    recipes = {
      ["Strength"] = { -- action name
        description="Increase your strength.", -- action description
        in_money=0, -- money taken per unit
        out_money=0, -- money earned per unit
        reagents={}, -- items taken per unit
        products={}, -- items given per unit
        aptitudes={ -- optional
          ["physical.strength"] = 1 -- "group.aptitude", give 1 exp per unit
        }
      }
    }
  },
  {
    name="Peaches",
    r=255,g=125,b=24,
    max_units=10,
    units_per_minute=1,
    x=-2141.46630859375,y=-79.5226974487305,z=53.7380447387695,
    radius=15, height=4,
    recipes = {
      ["Harvest"] = {
        description="Harvest peaches.",
        in_money=0,
        out_money=0,
        reagents={},
        products={
          ["edible|peach"] = 3
        }
      }
    }
  },
  {
    name="Peaches",
    r=255,g=125,b=24,
    max_units=10,
    units_per_minute=1,
    x=-2185.3857421875,y=-43.3630828857422,z=74.495719909668,
    radius=15, height=4,
    recipes = {
      ["Harvest"] = {
        description="Harvest peaches.",
        in_money=0,
        out_money=0,
        reagents={},
        products={
          ["edible|peach"] = 3
        }
      }
    }
  },
  {
    name="Peaches",
    r=255,g=125,b=24,
    max_units=10,
    units_per_minute=1,
    x=-2217.4716796875,y=33.9435615539551,z=111.254753112793,
    radius=15, height=4,
    recipes = {
      ["Harvest"] = {
        description="Harvest peaches.",
        in_money=0,
        out_money=0,
        reagents={},
        products={
          ["edible|peach"] = 3
        }
      }
    }
  },
  {
    name="Peaches resale",
    r=255,g=125,b=24,
    max_units=1000,
    units_per_minute=1000,
    x=-1484.080078125,y=-397.131927490234,z=38.3666610717773,
    radius=5, height=2.5,
    recipes = {
      ["Sell"] = {
        description="Sell peaches. 25$ per 5.",
        in_money=0,
        out_money=25,
        reagents = {
          ["edible|peach"] = 5
        },
        products={}
      }
    }
  },
  {
    name="Gold deposit",
    r=255,g=255,b=0,
    max_units=1000,
    units_per_minute=5,
    x=123.05940246582,y=3336.2939453125,z=30.7280216217041,
    radius=30, height=8,
    recipes = { 
      ["Search"] = {
        description="Search for gold.",
        in_money=0,
        out_money=0,
        reagents={},
        products={
          ["gold_ore"] = 1
        }
      }
    }
  },
  {
    name="Gold processing",
    r=255,g=255,b=0,
    max_units=1000,
    units_per_minute=1000,
    x=-75.9527359008789,y=6495.42919921875,z=31.4908847808838,
    radius=24, height=2,
    recipes = {
      ["Process ore"] = {
        description="Process gold ore.",
        in_money=0,
        out_money=0,
        reagents={
          ["gold_ore"] = 1
        },
        products={
          ["gold_processed"] = 1
        }
      }
    }
  },
  {
    name="Gold refinement",
    r=255,g=255,b=0,
    max_units=1000,
    units_per_minute=1000,
    x=1032.71105957031,y=2516.86010742188,z=46.6488876342773,
    radius=24,height=4,
    recipes = {
      ["Refine"] = {
        description="Transform 10 processed gold into a gold ingot using a gold catalyst.",
        in_money=0,
        out_money=0,
        reagents={
          ["gold_processed"] = 10,
          ["gold_catalyst"] = 1
        },
        products={
          ["gold_ingot"] = 1
        },
      }
    }
  },
  {
    name="Gold resale",
    r=255,g=255,b=0,
    max_units=1000,
    units_per_minute=1000,
    x=-139.963653564453,y=-823.515258789063,z=31.4466247558594, 
    radius=8,height=1.5,
    recipes = {
      ["Sell gold"] = {
        description="Sell gold ingots, 1000$ per ingot.",
        in_money=0,
        out_money=2000,
        reagents={
          ["gold_ingot"] = 1
        },
        products={}
      }
    }
  }
}

return cfg
