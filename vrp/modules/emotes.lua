
-- this module define the emotes menu

local cfg = module("cfg/emotes")
local lang = vRP.lang

local emotes = cfg.emotes

local function ch_emote(player,choice)
  local emote = emotes[choice]
  if emote then
    vRPclient.playAnim(player,{emote[1],emote[2],emote[3]})
  end
end

-- add emotes menu to main menu

vRP.registerMenuBuilder("main", function(add, data)
  local choices = {}
  choices[lang.emotes.title()] = {function(player, choice)
    -- build emotes menu
    local menu = {name=lang.emotes.title(),css={top="75px",header_color="rgba(0,125,255,0.75)"}}
    local user_id = vRP.getUserId(player)

    if user_id ~= nil then
      -- add emotes to the emote menu
      for k,v in pairs(emotes) do
        if vRP.hasPermissions(user_id, v.permissions or {}) then
          menu[k] = {ch_emote}
        end
      end
    end

    -- clear current emotes
    menu[lang.emotes.clear.title()] = {function(player,choice)
      vRPclient.stopAnim(player,{true}) -- upper
      vRPclient.stopAnim(player,{false}) -- full
    end, lang.emotes.clear.description()}

    vRP.openMenu(player,menu)
  end}
  add(choices)
end)
