
local Audio = class("Audio", vRP.Extension)

function Audio:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/audio")
end

-- EVENT
Audio.event = {}

function Audio.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- send peer config
    self.remote._setPeerConfiguration(user.source, self.cfg.voip_peer_configuration)
  end
end

-- TUNNEL
Audio.tunnel = {}

-- VoIP

function Audio.tunnel:signalVoicePeer(player, data)
  self.remote._signalVoicePeer(player, source, data)
end

vRP:registerExtension(Audio)
