
description "vRP MySQL async"

-- server scripts
server_scripts{ 
  "@vrp/lib/utils.lua",
  "init.lua",
  "mysql.net.dll"
}

server_exports{
  "createConnection",
  "createCommand",
  "query",
  "checkTask"
}
