
local cfg = {}

-- default flats positions from https://github.com/Nadochima/HomeGTAV/blob/master/List

-- define the home slots (each entry coordinate should be unique for ALL types)
cfg.slot_types = {
  ["basic_flat"] = {
    -- slots entry point coordinates
    {-782.171,324.589,223.258},
    {-774.171,333.589,207.621},
    {-774.171,333.589,159.998},
    {-596.689,59.139,108.030},
    {-1451.557,-523.546,69.556},
    {-1452.185,-522.640,56.929},
    {-907.900,-370.608,109.440},
    {-921.124,-381.099,85.480},
    {-464.453,-708.617,77.086},
    {-470.647,-689.459,53.402}
  },
  ["other_flat"] = {
    {-784.363,323.792,211.996},
    {-603.997,58.954,98.200},
    {-1453.013,-539.629,74.044},
    {-912.547,-364.706,114.274},
  }
}

-- define home clusters
cfg.homes = {
  ["Basic Housing 1"] = {
    slot = "basic_flat",
    entry_point = {-635.665,44.155,42.697},
    buy_price = 100000,
    sell_price = 80000,
    max = 99,
    blipid=40,
    blipcolor=4
  },
  ["Basic Housing 2"] = {
    slot = "basic_flat",
    entry_point = {-1446.769,-538.531,34.740},
    buy_price = 100000,
    sell_price = 80000,
    max = 99,
    blipid=40,
    blipcolor=4
  },
  ["Rich Housing"] = {
    slot = "other_flat",
    entry_point = {-770.921,312.537,85.698},
    buy_price = 500000,
    sell_price = 300000,
    max = 10,
    blipid=40,
    blipcolor=5
  }
}

return cfg
