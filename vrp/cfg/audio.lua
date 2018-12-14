
local cfg = {}

-- VoIP

-- set to true to disable the default voice chat and use vRP voip instead (world channel) 
cfg.vrp_voip = false

-- radius to establish VoIP connections
cfg.voip_proximity = 100

-- connect/disconnect interval in milliseconds
cfg.voip_interval = 5000

-- VoIP websocket server
cfg.voip_server = "ws://localhost:40120"

-- world voice config (see Audio:registerVoiceChannel)
cfg.world_voice = {
  effects = {
    spatialization = { max_dist = cfg.voip_proximity }
  }
}

return cfg
