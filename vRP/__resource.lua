
description "RP module/framework"

ui_page "gui/index.html"

-- server scripts
server_scripts{ 
  "base.lua",
  "modules/gui.lua",
  "modules/survival.lua",
  "modules/player_state.lua"
}

-- client scripts
client_scripts{
  "client/Tunnel.lua",
  "client/base.lua",
  "client/gui.lua",
  "client/player_state.lua",
  "client/map.lua"
}

-- client files
files{
  "gui/index.html",
  "gui/design.css",
  "gui/main.js",
  "gui/Menu.js"
}
