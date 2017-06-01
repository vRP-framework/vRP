
local cfg = {}

-- define each group with a set of permissions
-- _config property:
--- gtype (optional): used to have only one group with the same gtype per player (example: a job gtype to only have one job)
--- onspawn (optional): function(player) (called when the player spawn with the group)
--- onjoin (optional): function(player) (called when the player join the group)
--- onleave (optional): function(player) (called when the player leave the group)
--- (you have direct access to vRP and vRPclient, the tunnel to client, in the config callbacks)

cfg.groups = {
  ["superadmin"] = {
    _config = {onspawn = function(player) vRPclient.notify(player,{"You are superadmin."}) end},
    "player.group.add",
    "player.group.remove",
    "player.givemoney",
    "player.giveitem"
  },
  ["admin"] = {
    "admin.tickets",
    "player.list",
    "player.whitelist",
    "player.unwhitelist",
    "player.kick",
    "player.ban",
    "player.unban",
    "player.noclip",
    "player.custom_emote",
    "player.coords",
    "player.tptome",
    "player.tpto"
  },
  -- the group user is auto added to all logged players
  ["user"] = {
    "player.phone",
    "player.calladmin",
    "police.askid"
  },
  ["police"] = {
    _config = { 
      gtype = "job",
      onjoin = function(player) vRPclient.setCop(player,{true}) end,
      onspawn = function(player) vRPclient.setCop(player,{true}) end,
      onleave = function(player) vRPclient.setCop(player,{false}) end
    },
    "police.cloakroom",
    "police.pc",
    "police.handcuff",
    "police.putinveh",
    "police.check",
    "police.service",
    "police.wanted",
    "police.seize.weapons",
    "police.seize.items"
  },
  ["emergency"] = {
    _config = { gtype = "job" },
    "emergency.revive",
    "emergency.shop",
    "emergency.service"
  },
  ["taxi"] = {
    _config = { gtype = "job" },
    "taxi.service"
  },
  ["citizen"] = {
    _config = { gtype = "job" }
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
--- x,y,z, blipid, blipcolor permission (optional)

cfg.selectors = {
  ["Job Selector"] = {
    _config = {x = -268.363739013672, y = -957.255126953125, z = 31.22313880920410, blipid = 351, blipcolor = 47},
    "police",
    "taxi",
    "citizen"
  }
}

return cfg

