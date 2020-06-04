-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.emotes then return end

-- this module define the emotes menu

local lang = vRP.lang

local ActionDelay = module("vrp", "lib/ActionDelay")

local Emotes = class("Emotes", vRP.Extension)

-- SUBCLASS

Emotes.User = class("User")

function Emotes.User:__construct()
  self.emotes_action = ActionDelay()
end

-- METHODS

function Emotes:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/emotes")

  self:log(#self.cfg.emotes.." emotes from config")

  local function m_emote(menu, value)
    local user = menu.user

    local emote = self.cfg.emotes[value]
    if user.emotes_action:perform(emote[5] or 0) then
      vRP.EXT.Base.remote._playAnim(user.source,emote[2],emote[3],emote[4])
    else
      vRP.EXT.Base.remote._notify(user.source, lang.common.must_wait({user.emotes_action:remaining()}))
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
function Emotes:add(config)
  table.insert(self.cfg.emotes, config)
end

vRP:registerExtension(Emotes)
