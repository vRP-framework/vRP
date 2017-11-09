
local cfg = {}

-- define static item transformers
-- see https://github.com/ImagicTheCat/vRP to understand the item transformer concept/definition

cfg.item_transformers = {
  {
    name="Musculation", -- menu name
    r=255,g=125,b=0, -- color
    max_units=1000,
    units_per_minute=1000,
    x=-1202.96252441406,y=-1566.14086914063,z=4.61040639877319,
    radius=7.5, height=1.5, -- area
    recipes = {
      ["Force"] = { -- action name
        description="Accroître sa force", -- action description
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
    name="Pêches",
    r=255,g=125,b=24,
    max_units=10,
    units_per_minute=1,
    x=-2141.46630859375,y=-79.5226974487305,z=53.7380447387695,
    radius=15, height=4,
    recipes = {
      ["Récolter"] = {
        description="Récolter des pêches.",
        in_money=0,
        out_money=0,
        reagents={},
        products={
          ["fruit_peche"] = 3
        }
      }
    }
  },
  {
    name="Pêches",
    r=255,g=125,b=24,
    max_units=10,
    units_per_minute=1,
    x=-2185.3857421875,y=-43.3630828857422,z=74.495719909668,
    radius=15, height=4,
    recipes = {
      ["Récolter"] = {
        description="Récolter des pêches.",
        in_money=0,
        out_money=0,
        reagents={},
        products={
          ["fruit_peche"] = 3
        }
      }
    }
  },
  {
    name="Pêches",
    r=255,g=125,b=24,
    max_units=10,
    units_per_minute=1,
    x=-2217.4716796875,y=33.9435615539551,z=111.254753112793,
    radius=15, height=4,
    recipes = {
      ["Récolter"] = {
        description="Récolter des pêches.",
        in_money=0,
        out_money=0,
        reagents={},
        products={
          ["fruit_peche"] = 3
        }
      }
    }
  },
  {
    name="Revente de pêches",
    r=255,g=125,b=24,
    max_units=1000,
    units_per_minute=1000,
    x=-1484.080078125,y=-397.131927490234,z=38.3666610717773,
    radius=5, height=2.5,
    recipes = {
      ["Vendre"] = {
        description="Vendre des pêches. 25$ les 5.",
        in_money=0,
        out_money=25,
        reagents = {
          ["fruit_peche"] = 5
        },
        products={}
      }
    }
  },
  {
    name="Gisement d'Or",
    r=255,g=255,b=0,
    max_units=1000,
    units_per_minute=5,
    x=123.05940246582,y=3336.2939453125,z=30.7280216217041,
    radius=30, height=8,
    recipes = { 
      ["Chercher de l'Or"] = {
        description="Chercher de l'Or",
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
    name="Traitement de l'Or",
    r=255,g=255,b=0,
    max_units=1000,
    units_per_minute=1000,
    x=-75.9527359008789,y=6495.42919921875,z=31.4908847808838,
    radius=24, height=2,
    recipes = {
      ["Traiter l'Or"] = {
        description="Traiter le minerais d'Or",
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
    name="Raffinement de l'Or",
    r=255,g=255,b=0,
    max_units=1000,
    units_per_minute=1000,
    x=1032.71105957031,y=2516.86010742188,z=46.6488876342773,
    radius=24,height=4,
    recipes = {
      ["Raffiner l'Or"] = {
        description="Transformer 10 Or traités en Lingot d'Or en utilisant un catalyseur d'Or.",
        in_money=0,
        out_money=0,
        reagents={
          ["gold_processed"] = 10,
          ["gold_catalyst"] = 1
        },
        products={
          ["gold_ingot"] = 1
        }
      }
    }
  },
  {
    name="Revente d'Or",
    r=255,g=255,b=0,
    max_units=1000,
    units_per_minute=1000,
    x=-139.963653564453,y=-823.515258789063,z=31.4466247558594, 
    radius=8,height=1.5,
    recipes = {
      ["Vendre l'Or"] = {
        description="Vendre des lingots d'Or, 1000$ par lingot.",
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

-- define transformers randomly placed on the map
cfg.hidden_transformers = {
  ["Récolte canabis"] = {
    def = {
      name="Canabis", -- menu name
      -- permission = "harvest.water_bottle", -- you can add a permission
      r=0,g=200,b=0, -- color
      max_units=500,
      units_per_minute=10,
      x=0,y=0,z=0, -- pos
      radius=10, height=1.8, -- area
      recipes = {
        ["Récolter"] = { -- action name
          description="Récolter le canabis", -- action description
          in_money=0, -- money taken per unit
          out_money=0, -- money earned per unit
          reagents={}, -- items taken per unit
          products={ -- items given per unit
            ["weed"] = 10
          }
        }
      }
    },
    positions = {
      {2224.19091796875,5576.9423828125,53.8465042114258},
      {-1011.81121826172,1049.76477050781,164.933609008789},
      {501.445129394531,6495.7001953125,30.4247779846191}
    }
  },
  ["Traitement canabis"] = {
    def = {
      name="Traitement du canabis", -- menu name
      -- permission = "harvest.water_bottle", -- you can add a permission
      r=0,g=200,b=0, -- color
      max_units=1000,
      units_per_minute=1000,
      x=0,y=0,z=0, -- pos
      radius=8, height=1.8, -- area
      recipes = {
        ["Traiter"] = { -- action name
          description="Traiter le canabis", -- action description
          in_money=0, -- money taken per unit
          out_money=0, -- money earned per unit
          reagents={
            ["weed"] = 2,
            ["demineralized_water"] = 1
          }, -- items taken per unit
          products={ -- items given per unit
            ["weed_processed"] = 1
          }
        }
      }
    },
    positions = {
      {1443.16345214844,6332.486328125,23.981897354126},
      {1581.90747070313,2910.68334960938,56.9333839416504},
      {2154.8515625,3386.4052734375,45.5702743530273}
    }
  },
  ["Revente canabis"] = {
    def = {
      name="Vente du canabis", -- menu name
      -- permission = "harvest.water_bottle", -- you can add a permission
      r=0,g=200,b=0, -- color
      max_units=1000,
      units_per_minute=1000,
      x=0,y=0,z=0, -- pos
      radius=5, height=1.8, -- area
      recipes = {
        ["Vendre"] = { -- action name
          description="Vendre le canabis traité", -- action description
          in_money=0, -- money taken per unit
          out_money=0, -- money earned per unit
          reagents={
            ["weed_processed"] = 10
          }, -- items taken per unit
          products={ -- items given per unit
            ["dirty_money"] = 5000
          }
        }
      }
    },
    positions = {
      {-410.352722167969,447.736328125,112.580322265625},
      {-1907.70776367188,292.63720703125,88.6077499389648},
      {-970.378356933594,-1121.73522949219,2.17184591293335},
      {340.481842041016,-1856.76635742188,27.3206825256348},
      {-585.191833496094,-1606.83642578125,27.010814666748},
      {238.181610107422,-2021.85290527344,18.3191604614258}
    }
  }

}

-- time in minutes before hidden transformers are relocated (min is 5 minutes)
cfg.hidden_transformer_duration = 5*24*60 -- 5 days

-- configure the information reseller (can sell hidden transformers positions)
cfg.informer = {
  infos = {
    ["Récolte canabis"] = 25000,
    ["Traitement canabis"] = 25000,
    ["Revente canabis"] = 25000
  },
  positions = {
    {-1203.77490234375,461.014465332031,91.8671264648438},
    {-1072.02038574219,-1073.34985351563,2.15036082267761},
    {234.083740234375,643.559936523438,186.398941040039},
    {-375.793731689453,6219.86865234375,31.4890422821045}
  },
  interval = 30, -- interval in minutes for the reseller respawn
  duration = 15, -- duration in minutes of the spawned reseller
  blipid = 133,
  blipcolor = 2
}

return cfg
