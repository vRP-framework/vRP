
local Radio = class("Radio", vRP.Extension)

function Radio:__construct()
  vRP.Extension.__construct(self)

  self.talking = false

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

function Radio.event.radioSpeakingChange(speaking)
  vRP.EXT.Audio:setVoiceState("world", speaking)
  vRP.EXT.Audio:setVoiceState("radio", speaking)
end

-- TUNNEL
Radio.tunnel = {}

function Radio.tunnel:setupRadio(players)
  for player in pairs(players) do
    vRP.EXT.Audio:connectVoice("radio", player)
  end
end

vRP:registerExtension(Radio)
