
local cfg = {}

-- define shop types
-- _config: {.map_entity, .permissions}
--- map_entity: {ent,cfg} will fill cfg.title, cfg.pos
--- permissions: (optional)

cfg.shop_types = {
  ["food"] = {
    _config = {map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1}}},

    -- list itemid => price
    -- Drinks
    ["edible|milk"] = 2,
    ["edible|water"] = 2,
    ["edible|coffee"] = 4,
    ["edible|tea"] = 4,
    ["edible|icetea"] = 8,
    ["edible|orangejuice"] = 8,
    ["edible|gocagola"] = 12,
    ["edible|redgull"] = 12,
    ["edible|lemonlimonad"] = 14,
    ["edible|vodka"] = 30,

    --Food
    ["edible|bread"] = 2,
    ["edible|donut"] = 2,
    ["edible|tacos"] = 8,
    ["edible|sandwich"] = 20,
    ["edible|kebab"] = 20
  },
  ["chemicals"] = {
    _config = {map_entity = {"PoI", {blip_id = 52, blip_color = 46, marker_id = 1}}},
    ["gold_catalyst"] = 50,
    ["demineralized_water"] = 5
  },
  ["drugstore"] = {
    _config = {permissions={"emergency.shop"}, map_entity = {"PoI", {blip_id = 51, blip_color = 2, marker_id = 1}}},
    ["medkit"] = 75,
    ["edible|pills"] = 10
  },
  ["tools"] = {
    _config = {map_entity = {"PoI", {blip_id = 51, blip_color = 47, marker_id = 1}}},
    ["repairkit"] = 50,
    ["money_binder"] = 1
  },
  ["TCG"] = { -- need vRP-TCG extension
    _config = {map_entity = {"PoI", {blip_id = 408, blip_color = 2, marker_id = 1}}},
    ["tcgbooster|0|5"] = 10,
    ["tcgbooster|1|5"] = 100,
    ["tcgbooster|2|5"] = 1000,
    ["tcgbooster|3|5"] = 10000,
    ["tcgbooster|4|5"] = 100000
  },
  -- weapons
  -- for the native name, see https://wiki.fivem.net/wiki/Weapons (not all of them will work, look at client/player_state.lua for the real weapon list)
  ["sandyshores1"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_BOTTLE"] = 1000,
    ["wbody|WEAPON_BAT"] = 1500,
    ["wbody|WEAPON_KNUCKLE"] = 1500,
    ["wbody|WEAPON_KNIFE"] = 2000
  },

  ["vinewood1"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_MARKSMANPISTOL"] = 1500,
    ["wbody|WEAPON_SNSPISTOL"] = 2500,
    ["wbody|WEAPON_VINTAGEPISTOL"] = 2500,
    ["wbody|WEAPON_PISTOL"] = 2500,
    ["wbody|WEAPON_COMBATPISTOL"] = 5000,
    ["wbody|WEAPON_HEAVYPISTOL"] = 5000,
    ["wbody|WEAPON_HEAVYREVOLVER"] = 5000,
    ["wbody|WEAPON_APPISTOL"] = 7500,
    ["wammo|WEAPON_MARKSMANPISTOL"] = 15,
    ["wammo|WEAPON_SNSPISTOL"] = 15,
    ["wammo|WEAPON_VINTAGEPISTOL"] = 15,
    ["wammo|WEAPON_PISTOL"] = 15,
    ["wammo|WEAPON_COMBATPISTOL"] = 15,
    ["wammo|WEAPON_HEAVYPISTOL"] = 15,
    ["wammo|WEAPON_HEAVYREVOLVER"] = 15,
    ["wammo|WEAPON_APPISTOL"] = 15,

    ["wbody|WEAPON_DAGGER"] = 2000,
    ["wbody|WEAPON_HAMMER"] = 2500,
    ["wbody|WEAPON_HATCHET"] = 3000
  },

  ["vespuccibeach1"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_MICROSMG"] = 50000,
    ["wbody|WEAPON_SMG"] = 5000,
    ["wbody|WEAPON_ASSAULTSMG"] = 5500,
    ["wbody|WEAPON_COMBATPDW"] = 7500,
    ["wbody|WEAPON_MACHINEPISTOL"] = 7500,
    ["wammo|WEAPON_MICROSMG"] = 25,
    ["wammo|WEAPON_SMG"] = 25,
    ["wammo|WEAPON_ASSAULTSMG"] = 25,
    ["wammo|WEAPON_COMBATPDW"] = 25,
    ["wammo|WEAPON_MACHINEPISTOL"] = 25,
    ["wbody|WEAPON_NIGHTSTICK"] = 3000,
    ["wbody|WEAPON_CROWBAR"] = 3000,
    ["wbody|WEAPON_GOLFCLUB"] = 3500,
    ["wbody|WEAPON_SWITCHBLADE"] = 4000,
    ["wbody|WEAPON_MACHETE"] = 4500
  },

  ["paletobay1"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_MARKSMANPISTOL"] = 1500,
    ["wbody|WEAPON_SNSPISTOL"] = 2500,
    ["wbody|WEAPON_COMPACTRIFLE"] = 200000,
    ["wbody|WEAPON_ASSAULTRIFLE"] = 200000,
    ["wbody|WEAPON_CARBINERIFLE"] = 200000,
    ["wbody|WEAPON_GRENADE"] = 500000,
    ["wbody|WEAPON_MOLOTOV"] = 150000,
    ["wbody|WEAPON_FLARE"] = 200000,
    ["wammo|WEAPON_MARKSMANPISTOL"] = 15,
    ["wammo|WEAPON_SNSPISTOL"] = 15,
    ["wammo|WEAPON_COMPACTRIFLE"] = 50,
    ["wammo|WEAPON_ASSAULTRIFLE"] = 50,
    ["wammo|WEAPON_CARBINERIFLE"] = 50,
    ["wammo|WEAPON_GRENADE"] = 70,
    ["wammo|WEAPON_MOLOTOV"] = 45,
    ["wammo|WEAPON_FLARE"] = 50
  },

  ["tataviammountains1"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 2, marker_id = 1}}},
    ["wbody|WEAPON_GUSENBERG"] = 200000,
    ["wbody|WEAPON_MG"] = 250000,
    ["wbody|WEAPON_COMBATMG"] = 500000,
    ["wammo|WEAPON_GUSENBERG"] = 50,
    ["wammo|WEAPON_MG"] = 50,
    ["wammo|WEAPON_COMBATMG"] = 70
  },

  ["chumash1"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_MARKSMANPISTOL"] = 1500,
    ["wbody|WEAPON_SNSPISTOL"] = 2500,
    ["wbody|WEAPON_MARKSMANRIFLE"] = 150000,
    ["wbody|WEAPON_SNIPERRIFLE"] = 200000,
    ["wbody|WEAPON_HEAVYSNIPER"] = 500000,
    ["wammo|WEAPON_MARKSMANPISTOL"] = 15,
    ["wammo|WEAPON_SNSPISTOL"] = 15,
    ["wammo|WEAPON_MARKSMANRIFLE"] = 45,
    ["wammo|WEAPON_SNIPERRIFLE"] = 50,
    ["wammo|WEAPON_HEAVYSNIPER"] = 50
  },

  ["eastlossantos1"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_BULLPUPRIFLE"] = 200000,
    ["wbody|WEAPON_ADVANCEDRIFLE"] = 200000,
    ["wbody|WEAPON_SPECIALCARBINE"] = 200000,
    ["wbody|WEAPON_GRENADE"] = 500000,
    ["wbody|WEAPON_MOLOTOV"] = 150000,
    ["wbody|WEAPON_FLARE"] = 200000,
    ["wammo|WEAPON_BULLPUPRIFLE"] = 50,
    ["wammo|WEAPON_ADVANCEDRIFLE"] = 50,
    ["wammo|WEAPON_SPECIALCARBINE"] = 50,
    ["wammo|WEAPON_GRENADE"] = 70,
    ["wammo|WEAPON_MOLOTOV"] = 45,
    ["wammo|WEAPON_FLARE"] = 50
  },

  ["midlossantosrange"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_SAWNOFFSHOTGUN"] = 350000,
    ["wbody|WEAPON_PUMPSHOTGUN"] = 500000,
    ["wbody|WEAPON_BULLPUPSHOTGUN"] = 650000,
    ["wbody|WEAPON_HEAVYSHOTGUN"] = 750000,
    ["wbody|WEAPON_ASSAULTSHOTGUN"] = 1000000,
    ["wammo|WEAPON_SAWNOFFSHOTGUN"] = 65,
    ["wammo|WEAPON_PUMPSHOTGUN"] = 70,
    ["wammo|WEAPON_BULLPUPSHOTGUN"] = 72,
    ["wammo|WEAPON_HEAVYSHOTGUN"] = 75,
    ["wammo|WEAPON_ASSAULTSHOTGUN"] = 80
  },

  ["greatchaparral1"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_GRENADELAUNCHER_SMOKE"] = 500000,
    ["wammo|WEAPON_GRENADELAUNCHER_SMOKE"] = 100,
    ["wbody|WEAPON_FIREEXTINGUISHER"] = 1000000,
    ["wbody|WEAPON_FIREWORK"] = 2000000,
    ["wbody|WEAPON_SNOWBALL"] = 3000000,
    ["wbody|WEAPON_FLASHLIGHT"] = 50000,
    ["wbody|WEAPON_STUNGUN"] = 100000,
    ["wbody|WEAPON_MUSKET"] = 150000,
    ["wbody|WEAPON_FLAREGUN"] = 500000
  },

  ["cypressflatsrange1"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_MARKSMANPISTOL"] = 1500,
    ["wbody|WEAPON_SNSPISTOL"] = 2500,
    ["wbody|WEAPON_GRENADE"] = 500000,
    ["wammo|WEAPON_MARKSMANPISTOL"] = 15,
    ["wammo|WEAPON_SNSPISTOL"] = 15,
    ["wammo|WEAPON_GRENADE"] = 70,
    ["wbody|WEAPON_SMOKEGRENADE"] = 50000,
    ["wbody|WEAPON_PETROLCAN"] = 50000
  },
  ["melee weapons"] = {
    _config = {map_entity = {"PoI", {blip_id = 154, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_KNIFE"] = 75,
    ["wbody|WEAPON_MACHETE"] = 250
  },
  ["handguns"] = {
    _config = {map_entity = {"PoI", {blip_id = 156, blip_color = 1, marker_id = 1}}},
    ["wbody|WEAPON_PISTOL"] = 550,
    ["wbody|WEAPON_COMBATPISTOL"] = 950,
    ["wammo|WEAPON_PISTOL|50"] = 20,
    ["wammo|WEAPON_COMBATPISTOL|50"] = 20
  },
  ["gear"] = {
    _config = {map_entity = {"PoI", {blip_id = 175, blip_color = 1, marker_id = 1}}},
    ["bulletproof_vest"] = 750
  }
}

-- list of shops {type,x,y,z}

cfg.shops = {
  {"food",128.1410369873, -1286.1120605469, 29.281036376953},
  {"food",-47.522762298584,-1756.85717773438,29.4210109710693},
  {"food",25.7454013824463,-1345.26232910156,29.4970207214355}, 
  {"food",1135.57678222656,-981.78125,46.4157981872559}, 
  {"food",1163.53820800781,-323.541320800781,69.2050552368164}, 
  {"food",374.190032958984,327.506713867188,103.566368103027}, 
  {"food",2555.35766601563,382.16845703125,108.622947692871}, 
  {"food",2676.76733398438,3281.57788085938,55.2411231994629}, 
  {"food",1960.50793457031,3741.84008789063,32.3437385559082},
  {"food",1393.23828125,3605.171875,34.9809303283691}, 
  {"food",1166.18151855469,2709.35327148438,38.15771484375}, 
  {"food",547.987609863281,2669.7568359375,42.1565132141113}, 
  {"food",1698.30737304688,4924.37939453125,42.0636749267578}, 
  {"food",1729.54443359375,6415.76513671875,35.0372200012207}, 
  {"food",-3243.9013671875,1001.40405273438,12.8307056427002}, 
  {"food",-2967.8818359375,390.78662109375,15.0433149337769}, 
  {"food",-3041.17456054688,585.166198730469,7.90893363952637}, 
  {"food",-1820.55725097656,792.770568847656,138.113250732422}, 
  {"food",-1486.76574707031,-379.553985595703,40.163387298584}, 
  {"food",-1223.18127441406,-907.385681152344,12.3263463973999}, 
  {"food",-707.408996582031,-913.681701660156,19.2155857086182},

  -- {"TCG",-1223.18127441406,-907.385681152344,12.3263463973999},
  {"tools",-707.408996582031,-913.681701660156,19.2155857086182},
  {"chemicals",1163.79260253906,2705.58544921875,38.1576995849609},
  {"drugstore",-497.977142333984,-328.329895019531,34.501636505127},
  {"gear", 844.76324462891,-1029.4772949219,28.194856643677},

  -- weapons
  --[[
  {"sandyshores1", 1692.41, 3758.22, 34.7053},
  {"vinewood1", 252.696, -48.2487, 69.941},
  {"eastlossantos1", 844.299, -1033.26, 28.1949},
  {"paletobay1", -331.624, 6082.46, 31.4548},
  {"vespuccibeach1", -664.147, -935.119, 21.8292},
  {"delperro1", -1320.983, -389.260, 36.483},
  {"greatchaparral1", -1119.48803710938,2697.08666992188,18.5541591644287},
  {"tataviammountains1", 2569.62, 294.453, 108.735},
  {"chumash1", -3172.60375976563,1085.74816894531,20.8387603759766},
  {"midlossantosrange", 21.70, -1107.41, 29.79},
  {"cypressflatsrange1", 810.15, -2156.88, 29.61}
  --]]
  {"melee weapons", 21.70, -1107.41, 29.79},
  {"handguns", 844.299, -1033.26, 28.1949}

}

return cfg
