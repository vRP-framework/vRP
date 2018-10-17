
-- this module define the emotes menu

local lang = vRP.lang

local Emotes = class("Emotes", vRP.Extension)

function Emotes:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/emotes")

  self:log(#self.cfg.emotes.." emotes from config")

  local function m_emote(menu, value)
    local emote = self.cfg.emotes[value]
    if emote then
      vRP.EXT.Base.remote._playAnim(menu.user.source,emote[2],emote[3],emote[4])
    end
  end

  local function m_clear(menu)
    vRP.EXT.Base.remote._stopAnim(menu.user.source,true) -- upper
    vRP.EXT.Base.remote._stopAnim(menu.user.source,false) -- full
  end

  vRP.EXT.GUI:registerMenuBuilder("emotes", function(menu)
    menu.title = lang.emotes.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    -- add emotes
    for i,emote in ipairs(self.cfg.emotes) do
      if menu.user:hasPermissions(emote.permissions or {}) then
        menu:addOption(emote[1], m_emote, nil, i)
      end
    end

    -- add clear current emotes
    menu:addOption(lang.emotes.clear.title(), m_clear, lang.emotes.clear.description())
  end)

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption(lang.emotes.title(), function(menu)
      menu.user:openMenu("emotes")
    end)
  end)
end

-- add a new emote
-- see cfg/emotes.lua
function Emotes:add(title, upper, seq, looping)
  table.insert(self.cfg.emotes, {title, upper, seq, looping})
end

vRP:registerExtension(Emotes)
