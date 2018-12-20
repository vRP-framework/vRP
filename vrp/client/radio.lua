
local Radio = class("Radio", vRP.Extension)

function Radio:__construct()
  vRP.Extension.__construct(self)

  self.talking = false
  self.players = {}

  -- task: radio push to talk
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)

      local old_talking = self.talking
      self.talking = IsControlPressed(table.unpack(vRP.cfg.controls.radio))

      if old_talking ~= self.talking then
        vRP:triggerEvent("radioSpeakingChange", self.talking)
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
    vRP.EXT.Audio:connectVoice("radio", player)
    self.players[player] = data
  end
end

function Radio.tunnel:clearPlayers()
  vRP.EXT.Audio:disconnectVoice("radio")
  self.players = {}
end

vRP:registerExtension(Radio)
