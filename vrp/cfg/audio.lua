
local cfg = {}

-- VoIP

-- configuration passed to RTCPeerConnection
cfg.voip_peer_configuration = {
  iceServers = {
    {urls = {"stun:stun.l.google.com:19302", "stun:stun1.l.google.com:19302", "stun:stun2.l.google.com:19302"}}
  }
}

return cfg
