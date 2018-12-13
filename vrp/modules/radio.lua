
local lang = vRP.lang

local Radio = class("Radio", vRP.Extension)

-- SUBCLASS

Radio.User = class("User")

function Radio.User:connectRadio()
  local rusers = vRP.EXT.Radio.rusers

  if not rusers[self] then
    -- send map of players to connect to for this radio
    local groups = self:getGroups()
    local players = {}
    for ruser in pairs(rusers) do -- each radio user
      for group in pairs(groups) do -- each player group
        for cgroup in pairs(vRP.EXT.Radio.cgroups[group] or {}) do -- each group from connect graph for this group
          if ruser:hasGroup(cgroup) then -- if in group
            players[ruser.source] = true
          end
        end
      end
    end

    vRP.EXT.Audio.remote._playAudioSource(self.source, vRP.EXT.Radio.cfg.on_sound, 0.5)

    -- connect to all radio players
    vRP.EXT.Radio.remote._setupRadio(self.source, players)

    -- connect all radio players to this new one
    for player in pairs(players) do
      vRP.EXT.Audio.remote._connectVoice(self.source, "radio", player)
    end

    rusers[self] = true
  end
end

function Radio.User:disconnectRadio()
  local rusers = vRP.EXT.Radio.rusers

  if rusers[self] then
    rusers[self] = nil

    vRP.EXT.Audio.remote._playAudioSource(self.source, vRP.EXT.Radio.cfg.off_sound, 0.5)
    vRP.EXT.Radio.remote._disconnectVoice(self.source, "radio")
  end
end

-- METHODS

function Radio:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/radio")

  vRP.EXT.Audio:registerVoiceChannel("radio", self.cfg.radio_voice)

  self.cgroups = {} -- groups connect graph
  self.rusers = {} -- radio users, map of user

  -- build groups connect graph
  for k,v in pairs(self.cfg.channels) do
    for _,g1 in pairs(v) do
      local group = self.cgroups[g1]
      if not group then
        group = {}
        self.cgroups[g1] = group
      end

      for _,g2 in pairs(v) do
        group[g2] = true
      end
    end
  end

  -- main menu

  local function m_radio(menu)
    local user = menu.user

    if self.rusers[user] then
      user:disconnectRadio() 
    else
      user:connectRadio() 
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    local user = menu.user

    -- check if in a radio group
    local groups = user:getGroups()
    local ok = false
    for group in pairs(groups) do
      if self.cgroups[group] then
        ok = true
        break
      end
    end

    if ok then
      menu:addOption(lang.radio.title(), m_radio)
    end
  end)
end

-- EVENT
Radio.event = {}

function Radio.event:characterUnload(user)
  user:disconnectRadio()
end

function Radio.event:playerLeaveGroup(user)
  user:disconnectRadio()
end

function Radio.event:playerJoinGroup(user)
  user:disconnectRadio()
end

vRP:registerExtension(Radio)
