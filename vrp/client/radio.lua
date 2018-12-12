
local Radio = class("Radio", vRP.Extension)

function Radio:__construct()
  vRP.Extension.__construct(self)

  self.rplayers = {} -- radio players that can be accepted
  self.talking = false

  -- radio channel behavior
  vRP.EXT.Audio:registerVoiceCallbacks("radio", function(player)
    self:log("(vRPvoice-radio) requested by "..player)
    return (self.rplayers[player] ~= nil)
  end,
  function(player, is_origin)
    self:log("(vRPvoice-radio) connected to "..player)
  end,
  function(player)
    self:log("(vRPvoice-radio) disconnected from "..player)
  end)

  -- task: radio push to talk
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)

      local old_talking = self.talking
      self.talking = IsControlPressed(table.unpack(vRP.cfg.controls.radio))

      if old_talking ~= self.talking then
        vRP.EXT.Audio:setVoiceState("world", nil, talking)
        vRP.EXT.Audio:setVoiceState("radio", nil, talking)
      end
    end
  end)
end

-- EVENT
Radio.event = {}

function Radio.event:NUIready()
  -- radio channel config
  vRP.EXT.Audio:configureVoice("radio", vRP.cfg.radio_voice_config)
end

-- TUNNEL
Radio.tunnel = {}

function Radio.tunnel:setupRadio(players)
  self.rplayers = players
end

function Radio.tunnel:disconnectRadio()
  self.rplayers = {}
  vRP.EXT.Audio:disconnectVoice("radio")
end

vRP:registerExtension(Radio)
