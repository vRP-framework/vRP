
description "RP module/framework"

ui_page "gui/index.html"

-- server scripts
server_scripts{ 
  "lib/utils.lua",
  "base.lua",
  "modules/gui.lua",
  "modules/group.lua",
  "modules/admin.lua",
  "modules/survival.lua",
  "modules/player_state.lua",
  "modules/map.lua",
  "modules/money.lua",
  "modules/inventory.lua",
  "modules/identity.lua",
  "modules/business.lua",
  "modules/item_transformer.lua",
  "modules/emotes.lua",
  "modules/police.lua",
  "modules/home.lua",
  "modules/home_components.lua",
  "modules/mission.lua",
  "modules/aptitude.lua",

  -- basic implementations
  "modules/basic_phone.lua",
  "modules/basic_atm.lua",
  "modules/basic_market.lua",
  "modules/basic_gunshop.lua",
  "modules/basic_garage.lua",
  "modules/basic_items.lua",
  "modules/basic_skinshop.lua",
  "modules/cloakroom.lua",
  "modules/basic_radio.lua"
}

-- client scripts
client_scripts{
  "lib/utils.lua",
  "client/base.lua",
  "client/iplloader.lua",
  "client/gui.lua",
  "client/player_state.lua",
  "client/survival.lua",
  "client/map.lua",
  "client/identity.lua",
  "client/basic_garage.lua",
  "client/police.lua",
  "client/admin.lua",
  "client/basic_phone.lua",
  "client/basic_radio.lua"
}

-- client files
files{
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "lib/Debug.lua",
  "lib/Luaseq.lua",
  "lib/Tools.lua",
  "cfg/client.lua",
  "gui/index.html",
  "gui/design.css",
  "gui/main.js",
  "gui/Menu.js",
  "gui/ProgressBar.js",
  "gui/WPrompt.js",
  "gui/RequestManager.js",
  "gui/AnnounceManager.js",
  "gui/Div.js",
  "gui/dynamic_classes.js",
  "gui/AudioEngine.js",
  "gui/lib/libopus.wasm.js",
  "gui/images/voice_active.png",
  "gui/sounds/phone_dialing.ogg",
  "gui/sounds/phone_ringing.ogg",
  "gui/sounds/phone_sms.ogg",
  "gui/sounds/radio_on.ogg",
  "gui/sounds/radio_off.ogg"
}
