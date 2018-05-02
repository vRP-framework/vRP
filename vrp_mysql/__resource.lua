
description "vRP MySQL async"

dependency "vrp"

-- server scripts
server_scripts{ 
  "@vrp/lib/utils.lua",
  "mysql.net.dll",
  "init.lua"
}

server_exports{
  "createConnection",
  "createCommand",
  "query",
  "checkTask"
}
