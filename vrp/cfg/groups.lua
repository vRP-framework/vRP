
local cfg = {}

-- define each group with a set of permissions
-- _config property:
--- title (optional): group display name
--- gtype (optional): used to have only one group with the same gtype per player (example: a job gtype to only have one job)
--- onspawn (optional): function(user) (called when the character spawn with the group)
--- onjoin (optional): function(user) (called when the character join the group)
--- onleave (optional): function(user) (called when the character leave the group)

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
    "police.askid",
    "player.store_weapons",
    "police.seizable" -- can be seized
  },
  ["police"] = {
    _config = {
      title = "Police",
      gtype = "job",
      onjoin = function(user) vRP.EXT.Police.remote._setCop(user.source,true) end,
      onspawn = function(user) vRP.EXT.Police.remote._setCop(user.source,true) end,
      onleave = function(user) vRP.EXT.Police.remote._setCop(user.source,false) end
    },
    "police.menu",
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
    "emergency.service"
  },
  ["repair"] = {
    _config = {
      title = "Repair",
      gtype = "job"
    },
    "vehicle.repair",
    "vehicle.replace",
    "repair.service"
  },
  ["taxi"] = {
    _config = {
      title = "Taxi",
      gtype = "job"
    },
    "taxi.service"
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
--- x,y,z, blipid, blipcolor, permissions (optional)

cfg.selectors = {
  ["Job Selector"] = {
    _config = {x = -268.363739013672, y = -957.255126953125, z = 31.22313880920410, blipid = 351, blipcolor = 47},
    "police",
    "taxi",
    "repair",
    "citizen"
  }
}

return cfg

