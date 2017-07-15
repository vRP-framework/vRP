
description "vRP MySQL async"

-- server scripts
server_scripts{ 
  "mysql.net.dll"
}

server_exports{
  "createConnection",
  "createCommand",
  "query",
  "checkTask"
}
