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
  "modules/audio.lua",
  "modules/admin.lua",
  "modules/identity.lua",
  "modules/group.lua",
  "modules/transformer.lua",
  "modules/hidden_transformer.lua",
  "modules/inventory.lua",
  "modules/player_state.lua",
  "modules/survival.lua",
  "modules/money.lua",
  "modules/emotes.lua",
  "modules/atm.lua",
  "modules/phone.lua",
  "modules/aptitude.lua",
  "modules/shop.lua",
  "modules/skinshop.lua",
  "modules/mission.lua",
  "modules/cloak.lua",
  "modules/garage.lua",
  "modules/business.lua",
  "modules/home.lua",
  "modules/home_components.lua",
  "modules/police.lua",
  "modules/radio.lua",
  "modules/ped_blacklist.lua",
  "modules/veh_blacklist.lua",
  "modules/edible.lua",
  "modules/warp.lua",
  "modules/profiler.lua"
}

-- client scripts
client_scripts{
  "lib/utils.lua",
  "client/base.lua",
  "client/map.lua",
  "client/gui.lua",
  "client/audio.lua",
  "client/admin.lua",
  "client/player_state.lua",
  "client/survival.lua",
  "client/identity.lua",
  "client/phone.lua",
  "client/garage.lua",
  "client/police.lua",
  "client/radio.lua",
  "client/ped_blacklist.lua",
  "client/veh_blacklist.lua",
  "client/warp.lua",
  "client/iplloader.lua"
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
