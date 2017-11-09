
local cfg = {}
-- define garage types with their associated vehicles
-- (vehicle list: https://wiki.fivem.net/wiki/Vehicles)

-- each garage type is an associated list of veh_name/veh_definition 
-- they need a _config property to define the blip and the vehicle type for the garage (each vtype allow one vehicle to be spawned at a time, the default vtype is "default")
-- this is used to let the player spawn a boat AND a car at the same time for example, and only despawn it in the correct garage
-- _config: vtype, blipid, blipcolor, permissions (optional, only users with the permission will have access to the shop)

cfg.rent_factor = 0.1 -- 10% of the original price if a rent
cfg.sell_factor = 0.75 -- sell for 75% of the original price

cfg.garage_types = {
  ["compacts"]  = {
    _config = {vtype="car",blipid=50,blipcolor=4},
    ["blista"] = {"Blista", 15000, ""},
    ["brioso"] = {"Brioso R/A", 155000, ""},
    ["dilettante"] = {"Dilettante", 25000, ""},
    ["issi2"] = {"Issi", 18000, ""},
    ["panto"] = {"Panto", 85000, ""},
    ["prairie"] = {"Prairie", 30000, ""},
    ["rhapsody"] = {"Rhapsody", 120000, ""}
  },

  ["coupe"] = {
    _config = {vtype="car",blipid=50,blipcolor=4},
    ["cogcabrio"] = {"Cognoscenti Cabrio",180000, ""},
    ["exemplar"] = {"Exemplar", 200000, ""},
    ["F620"] = {"F620", 80000, ""},
    ["felon"] = {"Felon", 90000, ""},
    ["felon2"] = {"Felon GT", 95000, ""},
    ["jackal"] = {"Jackal", 60000, ""},
    ["oracle"] = {"Oracle", 80000, ""},
    ["oracle2"] = {"Oracle XS",82000, ""},
    ["sentinel"] = {"sentinel", 90000, ""},
    ["sentinel2"] = {"Sentinel XS", 60000, ""},
    ["windsor"] = {"Windsor",800000, ""},
    ["windsor2"] = {"Windsor Drop",850000, ""},
    ["zion"] = {"Zion", 60000, ""},
    ["zion2"] = {"Zion Cabrio", 65000, ""}
  },

  ["sports"] = {
    _config = {vtype="car",blipid=50,blipcolor=4},
    ["ninef"] = {"9F",120000, ""},
    ["ninef2"] = {"9F Cabrio",130000, ""},
    ["alpha"] = {"Alpha",150000, ""},
    ["banshee"] = {"Banshee",105000, ""},
    ["bestiagts"] = {"Bestia GTS",610000, ""},
    ["blista"] = {"Blista Compact",42000, ""},
    ["buffalo"] = {"Buffalo",35000, ""},
    ["buffalo2"] = {"Buffalo S",96000, ""},
    ["carbonizzare"] = {"Carbonizzare",195000, ""},
    ["comet2"] = {"Comet",100000, ""},
    ["coquette"] = {"Coquette",138000, ""},
    ["tampa2"] = {"Drift Tampa",995000, ""},
    ["feltzer2"] = {"Feltzer",130000, ""},
    ["furoregt"] = {"Furore GT",448000, ""},
    ["fusilade"] = {"Fusilade",36000, ""},
    ["jester"] = {"Jester",240000, ""},
    ["jester2"] = {"Jester (Racecar)",350000, ""},
    ["kuruma"] = {"Kuruma",95000, ""},
    ["lynx"] = {"Lynx",1735000, ""},
    ["massacro"] = {"Massacro",275000, ""},
    ["massacro2"] = {"Massacro (Racecar)",385000, ""},
    ["omnis"] = {"Omnis",701000, ""},
    ["penumbra"] = {"Penumbra",24000, ""},
    ["rapidgt"] = {"Rapid GT",140000, ""},
    ["rapidgt2"] = {"Rapid GT Convertible",150000, ""},
    ["schafter3"] = {"Schafter V12",140000, ""},
    ["sultan"] = {"Sultan",12000, ""},
    ["surano"] = {"Surano",110000, ""},
    ["tropos"] = {"Tropos",816000, ""},
    ["verlierer2"] = {"Verkierer",695000,""}
  },

  ["sportsclassics"] = {
    _config = {vtype="car",blipid=50,blipcolor=5},
    ["casco"] = {"Casco",680000, ""},
    ["coquette2"] = {"Coquette Classic",665000, ""},
    ["jb700"] = {"JB 700",350000, ""},
    ["pigalle"] = {"Pigalle",400000, ""},
    ["stinger"] = {"Stinger",850000, ""},
    ["stingergt"] = {"Stinger GT",875000, ""},
    ["feltzer3"] = {"Stirling",975000, ""},
    ["ztype"] = {"Z-Type",950000,""}
  },

  ["supercars"] = {
    _config = {vtype="car",blipid=50,blipcolor=5},
    ["adder"] = {"Adder",1000000, ""},
    ["banshee2"] = {"Banshee 900R",565000, ""},
    ["bullet"] = {"Bullet",155000, ""},
    ["cheetah"] = {"Cheetah",650000, ""},
    ["entityxf"] = {"Entity XF",795000, ""},
    ["sheava"] = {"ETR1",199500, "4 - (less numner better car"},
    ["fmj"] = {"FMJ",1750000, "10 - (less numner better car"},
    ["infernus"] = {"Infernus",440000, ""},
    ["osiris"] = {"Osiris",1950000, "8 - (less numner better car"},
    ["le7b"] = {"RE-7B",5075000, "1 - (less numner better car"},
    ["reaper"] = {"Reaper",1595000, ""},
    ["sultanrs"] = {"Sultan RS",795000, ""},
    ["t20"] = {"T20",2200000,"7 - (less numner better car"},
    ["turismor"] = {"Turismo R",500000, "9 - (less numner better car"},
    ["tyrus"] = {"Tyrus",2550000, "5 - (less numner better car"},
    ["vacca"] = {"Vacca",240000, ""},
    ["voltic"] = {"Voltic",150000, ""},
    ["prototipo"] = {"X80 Proto",2700000, "6 - (less numner better car"},
    ["zentorno"] = {"Zentorno",725000,"3 - (less numner better car"}
  },

  ["musclecars"] = {
    _config = {vtype="car",blipid=50,blipcolor=4},
    ["blade"] = {"Blade",160000, ""},
    ["buccaneer"] = {"Buccaneer",29000, ""},
    ["Chino"] = {"Chino",225000, ""},
    ["coquette3"] = {"Coquette BlackFin",695000, ""},
    ["dominator"] = {"Dominator",35000, ""},
    ["dukes"] = {"Dukes",62000, ""},
    ["gauntlet"] = {"Gauntlet",32000, ""},
    ["hotknife"] = {"Hotknife",90000, ""},
    ["faction"] = {"Faction",36000, ""},
    ["nightshade"] = {"Nightshade",585000, ""},
    ["picador"] = {"Picador",9000, ""},
    ["sabregt"] = {"Sabre Turbo",15000, ""},
    ["tampa"] = {"Tampa",375000, ""},
    ["virgo"] = {"Virgo",195000, ""},
    ["vigero"] = {"Vigero",21000, ""}
  },

  ["off-road"] = {
    _config = {vtype="car",blipid=50,blipcolor=4},
    ["bifta"] = {"Bifta",75000, ""},
    ["blazer"] = {"Blazer",8000, ""},
    ["brawler"] = {"Brawler",715000, ""},
    ["dubsta3"] = {"Bubsta 6x6",249000, ""},
    ["dune"] = {"Dune Buggy",20000, ""},
    ["rebel2"] = {"Rebel",22000, ""},
    ["sandking"] = {"Sandking",38000, ""},
    ["monster"] = {"The Liberator",550000, ""},
    ["trophytruck"] = {"The Liberator",550000, ""}
  },

  ["suvs"]  = {
    _config = {vtype="car",blipid=50,blipcolor=4},
    ["baller"] = {"Baller",90000, ""},
    ["cavalcade"] = {"Cavalcade",60000, ""},
    ["granger"] = {"Grabger",35000, ""},
    ["huntley"] = {"Huntley",195000, ""},
    ["landstalker"] = {"Landstalker",58000, ""},
    ["radi"] = {"Radius",32000, ""},
    ["rocoto"] = {"Rocoto",85000, ""},
    ["seminole"] = {"Seminole",30000, ""},
    ["xls"] = {"XLS",253000, ""}
  },

  ["vans"] = {
    _config = {vtype="car",blipid=50,blipcolor=4},
    ["bison"] = {"Bison",30000, ""},
    ["bobcatxl"] = {"Bobcat XL",23000, ""},
    ["gburrito"] = {"Gang Burrito",65000, ""},
    ["journey"] = {"Journey",15000, ""},
    ["minivan"] = {"Minivan",30000, ""},
    ["paradise"] = {"Paradise",25000, ""},
    ["rumpo"] = {"Rumpo",13000, ""},
    ["surfer"] = {"Surfer",11000, ""},
    ["youga"] = {"Youga",16000, ""}
  },

  ["sedans"] = {
    _config = {vtype="car",blipid=50,blipcolor=4},
    ["asea"] = {"Asea",1000000, ""},
    ["asterope"] = {"Asterope",1000000, ""},
    ["cognoscenti"] = {"Cognoscenti",1000000, ""},
    ["cognoscenti2"] = {"Cognoscenti(Armored)",1000000, ""},
    ["cognoscenti3"] = {"Cognoscenti 55",1000000, ""},
    ["zentorno"] = {"Cognoscenti 55(Armored)",1500000, ""},
    ["fugitive"] = {"Fugitive",24000, ""},
    ["glendale"] = {"Glendale",200000, ""},
    ["ingot"] = {"Ingot",9000, ""},
    ["intruder"] = {"Intruder",16000, ""},
    ["premier"] = {"Premier",10000, ""},
    ["primo"] = {"Primo",9000, ""},
    ["primo2"] = {"Primo Custom",9500, ""},
    ["regina"] = {"Regina",8000, ""},
    ["schafter2"] = {"Schafter",65000, ""},
    ["stanier"] = {"Stanier",10000, ""},
    ["stratum"] = {"Stratum",10000, ""},
    ["stretch"] = {"Stretch",30000, ""},
    ["superd"] = {"Super Diamond",250000, ""},
    ["surge"] = {"Surge",38000, ""},
    ["tailgater"] = {"Tailgater",55000, ""},
    ["warrener"] = {"Warrener",120000, ""},
    ["washington"] = {"Washington",15000, ""}
  },

  ["motorcycles"] = {
    _config = {vtype="bike",blipid=226,blipcolor=4},
    ["AKUMA"] = {"Akuma",9000, ""},
    ["bagger"] = {"Bagger",5000, ""},
    ["bati"] = {"Bati 801",15000, ""},
    ["bati2"] = {"Bati 801RR",15000, ""},
    ["bf400"] = {"BF400",95000, ""},
    ["carbonrs"] = {"Carbon RS",40000, ""},
    ["cliffhanger"] = {"Cliffhanger",225000, ""},
    ["daemon"] = {"Daemon",5000, ""},
    ["double"] = {"Double T",12000, ""},
    ["enduro"] = {"Enduro",48000, ""},
    ["faggio2"] = {"Faggio",4000, ""},
    ["gargoyle"] = {"Gargoyle",120000, ""},
    ["hakuchou"] = {"Hakuchou",82000, ""},
    ["hexer"] = {"Hexer",15000, ""},
    ["innovation"] = {"Innovation",90000, ""},
    ["lectro"] = {"Lectro",700000, ""},
    ["nemesis"] = {"Nemesis",12000, ""},
    ["pcj"] = {"PCJ-600",9000, ""},
    ["ruffian"] = {"Ruffian",9000, ""},
    ["sanchez"] = {"Sanchez",7000, ""},
    ["sovereign"] = {"Sovereign",90000, ""},
    ["thrust"] = {"Thrust",75000, ""},
    ["vader"] = {"Vader",9000, ""},
    ["vindicator"] = {"Vindicator",600000,""}
  },
  ["taxi"] = {
    _config = {vtype="car", blipid=56, blipcolor=5, permissions = {"taxi.vehicle"} },
    ["taxi"] = {"Taxi",100,""}
  },
  ["police"] = {
    _config = {vtype="car", blipid=50, blipcolor=38, permissions = {"police.vehicle"} },
    ["police"] = {"Basique",100,"Model basique."},
    ["police3"] = {"Classique",25000,"Model sport classique."},
    ["police2"] = {"Furtif",50000,"Model furtif."}
  },
  ["urgences"] = {
    _config = {vtype="car",blipid=61,blipcolor=3,permission={"emergency.vehicle"} },
    ["ambulance"] = {"Basic",100,""}
  },
  ["vélos"] = {
    _config = {vtype="bike",blipid=376,blipcolor=4},
    ["tribike"] = {"Tribike", 250, ""},
    ["BMX"] = {"BMX", 450, ""}
  },
  ["bateaux"] = {
    _config = {vtype="boat",blipid=427,blipcolor=4},
    ["dinghy"] = {"Dinghy", 50000, "Un zodiac."},
    ["dinghy2"] = {"Dinghy II", 50000, "Un zodiac."},
    ["dinghy3"] = {"Dinghy III", 50000, "Un zodiac."},
    ["dinghy4"] = {"Dinghy IV", 50000, "Un zodiac."},
    ["marquis"] = {"Marquis", 250000, "Un voilier."},
    ["seashark"] = {"Seashark", 9000, "Un jet-ski."},
    ["seashark2"] = {"Seashark II", 9000, "Un jet-ski."},
    ["seashark3"] = {"Seashark III", 9000, "Un jet-ski."},
    ["speeder"] = {"Speeder", 600000, "Un bateau rapide."},
    ["speeder2"] = {"Speeder II", 600000, "Un bateau rapide."},
    ["squalo"] = {"Squalo", 600000, "Un bateau rapide."},
    ["jetmax"] = {"JetMax", 600000, "Un bateau rapide."},
    ["toro"] = {"Toro", 600000, "Un bateau rapide."},
    ["toro2"] = {"Toro II", 600000, "Un bateau rapide."},
    ["tropic"] = {"Tropic", 600000, "Un bateau rapide."},
    ["tropic2"] = {"Tropic II", 600000, "Un bateau rapide."},
    ["predator"] = {"Predator", 600000, "Un bateau rapide."},
    ["suntrap"] = {"Suntrap", 250000, "Bateau de plaisance."}
  },
  ["avions"] = {
    _config = {vtype="fly",blipid=307,blipcolor=4},
    ["velum"] = {"Velum", 500000, "Avion à hélice."},
    ["velum2"] = {"Velum II", 500000, "Avion à hélice."},
    ["stunt"] = {"Stunt", 250000, "Petit avion à hélice."},
    ["mammatus"] = {"Mammatus", 250000, "Petit avion à hélice."},
    ["dodo"] = {"Dodo", 250000, "Petit avion à hélice."},
    ["duster"] = {"Duster", 105000, "Vieux avion à hélice."},
    ["cuban800"] = {"Cuban 800", 250000, "Petit avion à hélice."},
    ["luxor"] = {"Luxor", 3500000, "Jet privé."},
    ["luxor2"] = {"Luxor II", 3500000, "Jet privé."}
  },
  ["hélicos"] = {
    _config = {vtype="fly",blipid=43,blipcolor=4},
    ["maverick"] = {"Maverick", 150000, "Hélico d'entrée de gamme."},
    ["swift"] = {"Swift", 550000, "Hélico rapide."},
    ["swift2"] = {"Swift II", 550000, "Hélico rapide."},
    ["supervolito"] = {"Super Volito", 850000, "Hélico rapide."},
    ["supervolito2"] = {"Super Volito II", 850000, "Hélico rapide."},
    ["volatus"] = {"Volatus", 3500000, "Hélico haut de gamme."}
  },
  ["transport"] = {
    _config = {vtype="car",blipid=318,blipcolor=4},
    ["packer"] = {"Packer", 15000, "Remorqueur basique."},
    ["benson"] = {"Benson", 8000, "Camion basique."},
    ["bison"] = {"Bison", 12000, "Pickup basique."}
  },
  ["conteneur"] = {
    _config = {vtype="trailer",blipid=318,blipcolor=17},
    ["trailersmall"] = {"Petit", 3000, "Petit conteneur pour pickup."},
    ["trailers"] = {"Basic", 30000, "Conteneur moyen."},
    ["tanker"] = {"Tanker", 300000, "Gros conteneur."}
  }
}

-- {garage_type,x,y,z}
cfg.garages = {
  {"compacts",-356.146, -134.69, 39.0097},
  {"coupe",723.013, -1088.92, 22.1829},
  {"sports",-1145.67, -1991.17, 13.162},
  {"sportsclassics",1174.76, 2645.46, 37.7545},
  {"supercars",112.275, 6619.83, 31.8154},
  {"motorcycles",-205.789, -1308.02, 31.2916},
  {"taxi",-286.870056152344,-917.948181152344,31.080623626709},
  {"police",454.4,-1017.6,28.4},
  {"urgences",-492.08544921875,-336.749206542969,34.3731842041016},
  {"vélos",-352.038482666016,-109.240043640137,38.6970825195313},
  {"bateaux",-849.501281738281,-1367.69567871094,1.60516905784607},
  {"bateaux",1299.11730957031,4215.66162109375,33.9086799621582},
  {"bateaux",3867.17578125,4464.54248046875,2.72485375404358},
  {"avions",1640, 3236, 40.4},
  {"avions",2123, 4805, 41.19},
  {"avions",-1348, -2230, 13.9},
  {"hélicos",1750, 3260, 41.37},
  {"hélicos",-1233, -2269, 13.9},
  {"hélicos",-745, -1468, 5},
  {"conteneur",-978.674682617188,-2994.29028320313,13.945068359375},
  {"transport",-962.553039550781,-2965.82470703125,13.9450702667236}
}

return cfg
