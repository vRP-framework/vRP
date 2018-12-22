
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

-- radio additional CSS
cfg.css = [[
.radio_display > div[data-group="police"] > .group{
  color: #1971ff;
}

.radio_display > div[data-group="police"]{
  background-image: linear-gradient(to bottom, rgb(25, 58, 112, 0.75), rgba(0,0,0,0.75));
}
]]

-- map entities used to display player radio GPS signal per group
-- map of group => map_entity (with PlayerMark behavior)
--- map_entity: {ent, cfg} will fill cfg.player, cfg.title
-- _default: default map entity for undefined groups
cfg.group_map_entities = {
  _default = {"PlayerMark", {blip_id = 1, blip_color = 4}},
  police = {"PlayerMark", {blip_id = 60, blip_color = 38}}
}

return cfg
