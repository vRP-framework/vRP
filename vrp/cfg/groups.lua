
local cfg = {}

-- define each group with a set of permissions
-- _config property:
--- title (optional): group display name
--- gtype (optional): used to have only one group with the same gtype per player (example: a job gtype to only have one job)
--- onspawn (optional): function(user) (called when the character spawn with the group)
--- onjoin (optional): function(user) (called when the character join the group)
--- onleave (optional): function(user) (called when the character leave the group)

function police_init(user)
  local weapons = {}
  weapons["WEAPON_STUNGUN"] = {ammo=1000}
  weapons["WEAPON_COMBATPISTOL"] = {ammo=100}
  weapons["WEAPON_NIGHTSTICK"] = {ammo=0}
  weapons["WEAPON_FLASHLIGHT"] = {ammo=0}
  
  vRP.EXT.PlayerState.remote._giveWeapons(user.source,weapons,true)
  vRP.EXT.Police.remote._setCop(user.source,true)
  vRP.EXT.PlayerState.remote._setArmour(user.source,100)
end

function police_onjoin(user)
  police_init(user)
end

function police_onleave(user)
  vRP.EXT.PlayerState.remote._giveWeapons(user.source,{},true)
  vRP.EXT.Police.remote._setCop(user.source,false)
  vRP.EXT.PlayerState.remote._setArmour(user.source,0)
  user:removeCloak()
end

function police_onspawn(user)
  police_init(user)
end

cfg.groups = {
  ["superadmin"] = {
    _config = {onspawn = function(user) vRP.EXT.Base.remote._notify(user.source, "You are superadmin.") end},
    "player.group.add",
    "player.group.remove",
    "player.givemoney",
    "player.giveitem"
  },
  ["admin"] = {
    "admin.tickets",
    "admin.announce",
    "player.list",
    "player.whitelist",
    "player.unwhitelist",
    "player.kick",
    "player.ban",
    "player.unban",
    "player.noclip",
    "player.custom_emote",
    "player.custom_model",
    "player.custom_sound",
    "player.display_custom",
    "player.coords",
    "player.tptome",
    "player.tpto"
  },
  ["god"] = {
    "admin.god" -- reset survivals/health periodically
  },
  -- the group user is auto added to all logged players
  ["user"] = {
    "player.phone",
    "player.calladmin",
    "player.store_weapons",
    "police.seizable" -- can be seized
  },
  ["police"] = {
    _config = {
      title = "Police",
      gtype = "job",
      onjoin = police_onjoin,
      onspawn = police_onspawn,
      onleave = police_onleave
    },
    "police.menu",
    "police.askid",
    "police.cloakroom",
    "police.pc",
    "police.handcuff",
    "police.drag",
    "police.putinveh",
    "police.getoutveh",
    "police.check",
    "police.service",
    "police.wanted",
    "police.seize.weapons",
    "police.seize.items",
    "police.jail",
    "police.fine",
    "police.announce",
    "police.vehicle",
    "police.chest_seized",
    "-player.store_weapons",
    "-police.seizable" -- negative permission, police can't seize itself, even if another group add the permission
  },
  ["emergency"] = {
    _config = {
      title = "Emergency",
      gtype = "job"
    },
    "emergency.revive",
    "emergency.shop",
    "emergency.service",
    "emergency.vehicle",
    "emergency.cloakroom"
  },
  ["repair"] = {
    _config = {
      title = "Repair",
      gtype = "job"
    },
    "vehicle.repair",
    "vehicle.replace",
    "repair.service"
--    "mission.repair.satellite_dishes", -- basic mission
--    "mission.repair.wind_turbines" -- basic mission
  },
  ["taxi"] = {
    _config = {
      title = "Taxi",
      gtype = "job"
    },
    "taxi.service",
    "taxi.vehicle"
  },
  ["citizen"] = {
    _config = {
      title = "Citizen",
      gtype = "job"
    }
  }
}

-- groups are added dynamically using the API or the menu, but you can add group when an user join here
cfg.users = {
  [1] = { -- give superadmin and admin group to the first created user on the database
    "superadmin",
    "admin"
  }
}

-- group selectors
-- _config
--- x,y,z, map_entity, permissions (optional)
---- map_entity: {ent,cfg} will fill cfg.title, cfg.pos

cfg.selectors = {
  ["Jobs"] = {
    _config = {x = -268.363739013672, y = -957.255126953125, z = 31.22313880920410, map_entity = {"PoI", {blip_id = 351, blip_color = 47, marker_id = 1}}},
    "taxi",
    "repair",
    "citizen"
  },
  ["Police job"] = {
    _config = {x = 437.924987792969,y = -987.974182128906, z = 30.6896076202393, map_entity = {"PoI", {blip_id = 351, blip_color = 38, marker_id = 1}}},
    "police",
    "citizen"
  },
  ["Emergency job"] = {
    _config = {x=-498.959716796875,y=-335.715148925781,z=34.5017547607422, map_entity = {"PoI", {blip_id = 351, blip_color = 1, marker_id = 1}}},
    "emergency",
    "citizen"
  }
}

return cfg

