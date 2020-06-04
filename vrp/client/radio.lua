-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)


if not vRP.modules.radio then return end

local Radio = class("Radio", vRP.Extension)

function Radio:__construct()
  vRP.Extension.__construct(self)

  self.talking = false
  self.players = {} -- radio players, map of player server id => {.group, .group_title, .title, .map_entity}

  -- task: radio push to talk
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)

      local old_talking = self.talking
      self.talking = IsControlPressed(table.unpack(vRP.cfg.controls.radio))

      if old_talking ~= self.talking then -- change
        if not self.talking then -- delay off
          self.talking = true
          SetTimeout(vRP.cfg.push_to_talk_end_delay+1, function()
            if self.talking_time and GetGameTimer()-self.talking_time >= vRP.cfg.push_to_talk_end_delay then
              self.talking = false
              vRP:triggerEvent("radioSpeakingChange", self.talking)
              self.talking_time = nil
            end
          end)
        else -- instantaneous
          vRP:triggerEvent("radioSpeakingChange", self.talking)
          self.talking_time = GetGameTimer()
        end
      end
    end
  end)
end

-- EVENT
Radio.event = {}

function Radio.event:radioSpeakingChange(speaking)
  vRP.EXT.Audio:setVoiceState("world", speaking)
  vRP.EXT.Audio:setVoiceState("radio", speaking)
end

function Radio.event:voiceChannelPlayerSpeakingChange(channel, player, speaking)
  if channel == "radio" then
    if speaking then
      local data = self.players[player]
      if data then
      SendNUIMessage({act="set_radio_player_speaking_state", player = player, state = speaking, data = data})
      end
    else
      SendNUIMessage({act="set_radio_player_speaking_state", player = player, state = speaking})
    end
  end
end

-- TUNNEL
Radio.tunnel = {}

function Radio.tunnel:setupPlayers(players)
  for player, data in pairs(players) do
    -- add player marker
    local ment = data.map_entity[2]
    ment.player = player
    ment.title = "["..data.group_title.."] "..data.title
    vRP.EXT.Map:setEntity("vRP:radio:player_marker:"..player, data.map_entity[1], ment)

    vRP.EXT.Audio:connectVoice("radio", player)
    self.players[player] = data
  end
end

-- players: (optional) map of player server id to remove, if nil, will clear all players
function Radio.tunnel:clearPlayers(players)
  -- remove player markers
  for player, data in pairs(players or self.players) do
    vRP.EXT.Map:removeEntity("vRP:radio:player_marker:"..player)
  end

  if players then
    for player in pairs(players) do
      vRP.EXT.Audio:disconnectVoice("radio", player)
      self.players[player] = nil
    end
  else
    vRP.EXT.Audio:disconnectVoice("radio")
    self.players = {}
  end
end

vRP:registerExtension(Radio)
