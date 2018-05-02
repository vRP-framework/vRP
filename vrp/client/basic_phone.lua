local player_called
local in_call = false

function tvRP.phoneCallWaiting(player, waiting)
  if waiting then
    player_called = player
  else
    player_called = nil
  end
end

function tvRP.phoneHangUp()
  tvRP.disconnectVoice("phone", nil)
end

-- phone channel behavior
tvRP.registerVoiceCallbacks("phone", function(player)
  print("(vRPvoice-phone) requested by "..player)
  if player == player_called then
    player_called = nil
    return true
  end
end,
function(player, is_origin)
  print("(vRPvoice-phone) connected to "..player)
  in_call = true
  tvRP.setVoiceState("phone", nil, true)
  tvRP.setVoiceState("world", nil, true)
end,
function(player)
  print("(vRPvoice-phone) disconnected from "..player)
  in_call = false
  if not tvRP.isSpeaking() then -- end world voice if not speaking
    tvRP.setVoiceState("world", nil, false)
  end
end)

AddEventHandler("vRP:NUIready", function()
  -- phone channel config
  tvRP.configureVoice("phone", cfg.phone_voice_config)
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(500)
    if in_call then -- force world voice if in a phone call
      tvRP.setVoiceState("world", nil, true)
    end
  end
end)
