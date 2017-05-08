
-- this module define the emotes menu

local cfg = require("resources/vrp/cfg/emotes")
local lang = vRP.lang

local emotes = cfg.emotes

local menu = {name=lang.emotes.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}

-- clear current emotes
menu[lang.emotes.clear.title()] = {function(player,choice) 
  vRPclient.stopAnim(player,{true}) -- upper
  vRPclient.stopAnim(player,{false}) -- full
end, lang.emotes.clear.description()}

local function ch_emote(player,choice)
  local emote = emotes[choice]
  if emote then
    vRPclient.playAnim(player,emote)
  end
end

-- add emotes to the emote menu
for k,v in pairs(emotes) do
  menu[k] = {ch_emote}
end

-- add emotes menu to main menu

AddEventHandler("vRP:buildMainMenu",function(player) 
  local choices = {}
  choices[lang.emotes.title()] = {function() vRP.openMenu(player,menu) end}
  vRP.buildMainMenu(player,choices)
end)
