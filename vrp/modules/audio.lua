
local Audio = class("Audio", vRP.Extension)

function Audio:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/audio")
end

-- EVENT
Audio.event = {}

function Audio.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- connect VoIP
    self.remote._connectVoIP(user.source, self.cfg.voip_server)
  end
end

-- TUNNEL
Audio.tunnel = {}

-- VoIP

function Audio.tunnel:signalVoicePeer(player, data)
  self.remote._signalVoicePeer(player, source, data)
end

vRP:registerExtension(Audio)
