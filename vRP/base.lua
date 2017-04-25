
local MySQL = require("resources/vRP/lib/MySQL/MySQL")
local config = require("resources/vRP/cfg/main")

vRP = {}

-- open MySQL connection
vRP.sql = MySQL.open(config.db.host,config.db.user,config.db.password,config.db.database)


-- identification system
