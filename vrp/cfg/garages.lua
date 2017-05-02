
local cfg = {}

-- define garage types with their associated vehicles
-- (vehicle list: https://wiki.fivem.net/wiki/Vehicles)

-- each garage type is an associated list of veh_name/veh_definition 
-- they need a _config property to define the blip and the vehicle type for the garage (each vtype allow one vehicle to be spawned at a time, the default vtype is "default")
-- this is used to let the player spawn a boat AND a car at the same time for example, and only despawn it in the correct garage

cfg.garage_types = {
  ["cars"] = {
    _config = {vtype="car",blipid=50,blipcolor=4},
    -- define a vehicle entry: [native_name] = {display_name,price,description}
    ["lynx"] = {"Lynx", 20000, "Fast as the eyes of the lynx.<br />Good wheels. Proper engine. Polished body."}

  },
  ["luxury cars"] = {
    _config = {vtype="car",blipid=50,blipcolor=5},
    ["rapidgt2"] = {"Rapid GT 2", 200000, ""}
  },
  ["helicopters"] = {
    _config = {vtype="flying",blipid=43,blipcolor=4},
    ["swift"] = {"Swift", 300000, ""}

  },
  ["planes"] = {
    _config = {vtype="flying",blipid=307,blipcolor=4},
    ["jet"] = {"Jet", 300000, ""}

  },
  ["boats"] = {
    _config = {vtype="boat",blipid=427,blipcolor=4},
    ["tropic"] = {"Tropic", 120000, "A boat."}

  },
  ["bikes"] = {
    _config = {vtype="bike",blipid=226,blipcolor=4},
    ["BMX"] = {"BMX", 450, "A good bicycle."}
  }
}

-- {garage_type,x,y,z}
cfg.garages = {
  {"cars",-356.146, -134.69, 39.0097},
  {"cars",723.013, -1088.92, 22.1829},
  {"cars",-1145.67, -1991.17, 13.162},
  {"cars",1174.76, 2645.46, 37.7545},
  {"luxury cars",112.275, 6619.83, 31.8154},
  {"bikes",-207.978, -1309.64, -31.2939},
  {"planes",1640, 3236, 40.4},
  {"planes",2123, 4805, 41.19},
  {"planes",-1348, -2230, 13.9},
  {"helicopters",1750, 3260, 41.37},
  {"helicopters",-1233, -2269, 13.9},
  {"helicopters",-745, -1468, 5},
  {"boats",-849.5, -1368.64, 1.6},
  {"boats",1538, 3902, 30.35}
}

return cfg
