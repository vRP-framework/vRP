-- client-side vRP configuration

cfg = {}

cfg.iplload = true

cfg.voice_proximity = 50.0

cfg.gui = {
  anchor_minimap_width = 260,
  anchor_minimap_left = 60,
  anchor_minimap_bottom = 213
}

-- when health is under the threshold, player is in coma
-- set to 0 to disable coma
cfg.coma_threshold = 120

-- maximum duration of the coma in minutes
cfg.coma_duration = 10

-- if true, a player in coma will not be able to open the main menu
cfg.coma_disable_menu = true
