
description "RP module/framework"

ui_page "gui/index.html"

-- server scripts
server_scripts{ 
  "lib/utils.lua",
  "base.lua",
  "modules/map.lua",
  "modules/gui.lua",
  "modules/group.lua",
  "modules/admin.lua",
  "modules/player_state.lua",
  "modules/emotes.lua",
  "modules/survival.lua",
  "modules/identity.lua",
  "modules/money.lua",
  "modules/atm.lua",
  "modules/phone.lua",
  "modules/inventory.lua",
  "modules/aptitude.lua",
  "modules/shop.lua",
  --[[
  "modules/business.lua",
  "modules/item_transformer.lua",
  "modules/police.lua",
  "modules/home.lua",
  "modules/home_components.lua",
  "modules/mission.lua",

  -- basic implementations
  "modules/basic_garage.lua",
  "modules/basic_items.lua",
  "modules/basic_skinshop.lua",
  "modules/cloakroom.lua",
  "modules/basic_radio.lua"
  --]]
}

-- client scripts
client_scripts{
  "lib/utils.lua",
  "client/base.lua",
  "client/map.lua",
  "client/gui.lua",
  "client/admin.lua",
  "client/player_state.lua",
  "client/survival.lua",
  "client/identity.lua",
  "client/phone.lua",
  --[[
  "client/iplloader.lua",
  "client/basic_garage.lua",
  "client/police.lua",
  "client/basic_radio.lua"
  --]]
}

-- client files
files{
  "lib/Luaoop.lua",
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "lib/Debug.lua",
  "lib/Tools.lua",
  "client/vRP.lua",
  "vRPShared.lua",
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
