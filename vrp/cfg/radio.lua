
local cfg = {}

cfg.on_sound = "sounds/radio_on.ogg" 
cfg.off_sound = "sounds/radio_off.ogg" 

-- radio voice config (see Audio:registerVoiceChannel)
cfg.radio_voice = {
  effects = {
    biquad = { type = "bandpass", frequency = 1700, Q = 2},
    gain = { gain = 2}
  }
}

-- list of list of groups (each list define a channel of speaker/listener groups, an ensemble)
cfg.channels = {
  {"police"}
}

-- map entities used to display player radio GPS signal per group
-- map of group => map_entity (with PlayerMark behavior)
--- map_entity: {ent, cfg} will fill cfg.player, cfg.title
cfg.group_map_entities = {
  police = {"PlayerMark", {blip_id = 60, blip_color = 38}}
}

return cfg
