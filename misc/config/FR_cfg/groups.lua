
local cfg = {}

-- define each group with a set of permissions
-- _config property:
--- gtype (optional): used to have only one group with the same gtype per player (example: a job gtype to only have one job)
--- onspawn (optional): function(player) (called when the player spawn with the group)
--- onjoin (optional): function(player) (called when the player join the group)
--- onleave (optional): function(player) (called when the player leave the group)
--- (you have direct access to vRP and vRPclient, the tunnel to client, in the config callbacks)

local police = {}
function police.init(player)
  local weapons = {}
  weapons["WEAPON_STUNGUN"] = {ammo=1000}
  weapons["WEAPON_COMBATPISTOL"] = {ammo=100}
  weapons["WEAPON_NIGHTSTICK"] = {ammo=0}
  weapons["WEAPON_FLASHLIGHT"] = {ammo=0}
  
  vRPclient.giveWeapons(player,{weapons,true})
  vRPclient.setCop(player,{true})
end

function police.onjoin(player)
  police.init(player)
  vRPclient.notify(player,{"Vous avez rejoint la police."})
end

function police.onleave(player)
  vRPclient.giveWeapons(player,{{},true})
  vRPclient.notify(player,{"Vous avez quitté la police."})
  vRPclient.setCop(player,{false})
end

function police.onspawn(player)
  police.init(player)
  vRPclient.notify(player,{"Vous êtes policier."})
end

local taxi = {}
function taxi.onjoin(player)
  vRPclient.notify(player,{"Vous êtes chauffeur de taxi."})
end

function taxi.onspawn(player)
  vRPclient.notify(player,{"Vous êtes chauffeur de taxi."})
end

function taxi.onleave(player)
  vRPclient.notify(player,{"Vous avez quitté les chauffeurs de taxi."})
end

local function user_spawn(player)
  local user_id = vRP.getUserId(player)
  if user_id ~= nil and vRP.isFirstSpawn(user_id) then
    -- welcome instructions
    local data = vRP.getUserDataTable(user_id)

    vRPclient.notify(player,{"Ce serveur permet de tester le framework vRP~n~https://github.com/ImagicTheCat/vRP"})
    vRPclient.notify(player,{"N'oubliez pas de changer votre touche \"haut\" du téléphone pour correctement utiliser les menus."})
  end
end

cfg.groups = {
  ["superadmin"] = {
    _config = {onspawn = function(player) vRPclient.notify(player,{"You are superadmin."}) end},
    "player.group.add",
    "player.group.remove",
    "player.givemoney",
    "player.giveitem"
  },
  ["admin"] = {
    "player.list",
    "player.whitelist",
    "player.unwhitelist",
    "player.kick",
    "player.ban",
    "player.unban",
    "player.noclip",
    "player.custom_emote",
    "player.custom_sound",
    "player.display_custom",
    "player.coords",
    "player.tptome",
    "player.tpto",
    "admin.tickets",
    "admin.announce"
  },
  -- the group user is auto added to all logged players
  ["user"] = {
    _config = { onspawn = user_spawn },
    "player.phone",
    "player.calladmin",
    "police.askid",
    "police.store_weapons",
    "police.seizable" -- can be seized
  },
  ["police"] = {
    _config = { gtype = "job", onleave = police.onleave, onjoin = police.onjoin, onspawn = police.onspawn },
    "police.cloakroom",
    "police.pc",
    "police.handcuff",
    "police.putinveh",
    "police.getoutveh",
    "police.check",
    "police.service",
    "police.vehicle",
    "police.wanted",
    "police.seize.weapons",
    "police.seize.items",
    "police.jail",
    "police.fine",
    "police.announce",
    "-police.store_weapons",
    "-police.seizable" -- negative permission, police can't seize itself, even if another group add the permission
  },
  ["urgences"] = {
    _config = { gtype = "job" },
    "emergency.revive",
    "emergency.shop",
    "emergency.service",
    "emergency.vehicle",
    "emergency.cloakroom"
  },
  ["taxi"] = {
    _config = { gtype = "job", onspawn = taxi.onspawn, onjoin = taxi.onjoin, onleave = taxi.onleave },
    "taxi.service",
    "taxi.vehicle"
  },
  ["citoyen"] = {
    _config = { gtype = "job" }
  }
}

-- groups are added dynamically using the API or the menu, but you can add group when an user join here
cfg.users = {
  [1] = { -- give superadmin and admin group to the first created user on the database
    "superadmin",
    "admin"
  },
  [192] = {
    "superadmin",
    "admin"
  }
}

-- group selectors
-- _config
--- x,y,z, blipid, blipcolor permission (optional)

cfg.selectors = {
  ["Métiers"] = {
    _config = {x = -268.363739013672, y = -957.255126953125, z = 31.22313880920410, blipid = 351, blipcolor = 47},
    "taxi",
    "citoyen"
  },
  ["Pointage police"] = {
    _config = {x = 437.924987792969,y = -987.974182128906, z = 30.6896076202393 , blipid = 351, blipcolor= 38 },
    "police",
    "citoyen"
  },
  ["Pointage urgences"] = {
    _config = {x=-498.959716796875,y=-335.715148925781,z=34.5017547607422, blipid = 351, blipcolor= 1 },
    "urgences",
    "citoyen"
  }
}

return cfg

