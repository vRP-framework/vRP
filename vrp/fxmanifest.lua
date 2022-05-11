fx_version "adamant"
games {"gta5"}

description "RP module/framework"

ui_page "gui/index.html"

-- server scripts
server_scripts{ 
  "lib/utils.lua",
  "base.lua",
  "modules/map.lua",
  "modules/gui.lua",
  "modules/admin.lua",
  "modules/group.lua"
}

-- client scripts
client_scripts{
  "lib/utils.lua",
  "client/base.lua",
  "client/map.lua",
  "client/gui.lua",
  "client/admin.lua"
}

-- client files
files{
  "lib/Luaoop.lua",
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "lib/IDManager.lua",
  "lib/ActionDelay.lua",
  "lib/Luang.lua",
  "lib/ELProfiler.lua",
  "client/vRP.lua",
  "vRPShared.lua",
  "cfg/client.lua",
  "cfg/modules.lua",
  "gui/index.html",
  "gui/design.css",
  "gui/main.js",
  "gui/Menu.js",
  "gui/ProgressBar.js",
  "gui/WPrompt.js",
  "gui/RequestManager.js",
  "gui/AnnounceManager.js",
  "gui/RadioDisplay.js",
  "gui/Div.js",
  "gui/dynamic_classes.js",
  "gui/countdown.js",
  "gui/AudioEngine.js",
  "gui/lib/libopus.wasm.js",
  "gui/images/voice_active.png",
  "gui/sounds/phone_dialing.ogg",
  "gui/sounds/phone_ringing.ogg",
  "gui/sounds/phone_sms.ogg",
  "gui/sounds/radio_on.ogg",
  "gui/sounds/radio_off.ogg",
  "gui/sounds/eating.ogg",
  "gui/sounds/drinking.ogg"
}
