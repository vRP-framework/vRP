
local cfg = {}

-- VoIP

-- VoIP websocket server
cfg.voip_server = "ws://localhost:40120"

-- VoIP Opus params
cfg.voip_bitrate = 24000 -- bits/s

-- frame_size (ms)
-- 20,40,60; higher frame_size can result in lower quality, but less WebRTC overhead (~125 bytes per packet)
-- 20: best quality, ~6ko/s overhead
-- 40: ~3ko/s overhead
-- 60: ~2ko/s overhead
cfg.voip_frame_size = 60

-- set to true to disable the default voice chat and use vRP voip instead (world channel) 
cfg.vrp_voip = true

-- radius to establish VoIP connections
cfg.voip_proximity = 100

-- connect/disconnect interval in milliseconds
cfg.voip_interval = 5000

-- world voice config (see Audio:registerVoiceChannel)
cfg.world_voice = {
  effects = {
    spatialization = { max_dist = cfg.voip_proximity, ref_dist = 3 }
  }
}

return cfg
