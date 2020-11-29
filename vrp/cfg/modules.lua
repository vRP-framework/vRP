-- loaded client-side and server-side
--
-- enable/disable some modules
-- some modules may be required by others
-- it's recommended to disable things from the modules configurations directly if possible

local modules = {
  map = true,
  gui = true,
  audio = true,
  admin = true,
  identity = true,
  group = true,
  inventory = true,
  player_state = true,
  survival = true,
  money = true,
  emotes = true,
  atm = true,
  phone = true,
  aptitude = true,
  shop = true,
  skinshop = true,
  mission = true,
  cloak = true,
  garage = true,
  business = true,
  transformer = true,
  hidden_transformer = true,
  home = true,
  home_components = true,
  police = true,
  radio = true,
  ped_blacklist = true,
  veh_blacklist = true,
  edible = true,
  warp = true,
  --
  profiler = false
}

return modules
