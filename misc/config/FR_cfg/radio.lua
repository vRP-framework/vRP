
local cfg = {}

cfg.on_sound = "sounds/radio_on.ogg" 
cfg.off_sound = "sounds/radio_off.ogg" 

-- list of list of groups (each list define a channel of speaker/listener groups, an ensemble)
cfg.channels = {
  {"police"}
}

return cfg
