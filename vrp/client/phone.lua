
local Phone = class("Phone", vRP.Extension)

-- METHODS

function Phone:__construct()
  vRP.Extension.__construct(self)

  self.player_called = nil
  self.in_call = false

  -- phone channel behavior
  local GUI = vRP.EXT.GUI
  GUI:registerVoiceCallbacks("phone", function(player)
    self:log("(vRPvoice-phone) requested by "..player)
    if player == self.player_called then
      self.player_called = nil
      return true
    end
  end,
  function(player, is_origin)
    self:log("(vRPvoice-phone) connected to "..player)
    self.in_call = true
    GUI:setVoiceState("phone", nil, true)
    GUI:setVoiceState("world", nil, true)
  end,
  function(player)
    self:log("(vRPvoice-phone) disconnected from "..player)
    self.in_call = false
    if not GUI:isSpeaking() then -- end world voice if not speaking
      GUI:setVoiceState("world", nil, false)
    end
  end)

  -- world voice task
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(500)
      if self.in_call then -- force world voice if in a phone call
        GUI:setVoiceState("world", nil, true)
      end
    end
  end)
end

function Phone:hangUp()
  vRP.EXT.GUI:disconnectVoice("phone", nil)
end

-- EVENT
Phone.event = {}

function Phone.event:NUIready()
  -- phone channel config
  vRP.EXT.GUI:configureVoice("phone", vRP.cfg.phone_voice_config)
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
