
local Phone = class("Phone", vRP.Extension)

-- METHODS

function Phone:__construct()
  vRP.Extension.__construct(self)

  self.player_called = nil
  self.in_call = false

  -- phone channel behavior
  local Audio = vRP.EXT.Audio
  Audio:registerVoiceCallbacks("phone", function(player)
    self:log("(vRPvoice-phone) requested by "..player)
    if player == self.player_called then
      self.player_called = nil
      return true
    end
  end,
  function(player, is_origin)
    self:log("(vRPvoice-phone) connected to "..player)
    self.in_call = true
    Audio:setVoiceState("phone", nil, true)
    Audio:setVoiceState("world", nil, true)
  end,
  function(player)
    self:log("(vRPvoice-phone) disconnected from "..player)
    self.in_call = false
    if not Audio:isSpeaking() then -- end world voice if not speaking
      Audio:setVoiceState("world", nil, false)
    end
  end)

  -- world voice task
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(500)
      if self.in_call then -- force world voice if in a phone call
        Audio:setVoiceState("world", nil, true)
      end
    end
  end)
end

function Phone:hangUp()
  vRP.EXT.Audio:disconnectVoice("phone", nil)
end

-- EVENT
Phone.event = {}

function Phone.event:NUIready()
  -- phone channel config
  vRP.EXT.Audio:configureVoice("phone", vRP.cfg.phone_voice_config)
end

-- TUNNEL
Phone.tunnel = {}

function Phone.tunnel:setCallWaiting(player, waiting)
  if waiting then
    self.player_called = player
  else
    self.player_called = nil
  end
end

Phone.tunnel.hangUp = Phone.hangUp

vRP:registerExtension(Phone)
