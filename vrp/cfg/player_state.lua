
local cfg = {}

-- define the first spawn position/radius of the player (very first spawn on the server, or after death)
cfg.spawn_enabled = true -- set to false to disable the feature
cfg.spawn_position = {-538.70001220703,-214.91049194336,37.649784088135}
cfg.spawn_radius = 3

cfg.update_interval = 15 -- seconds

-- multiplayer models (to enable MP customization)
-- list of names (string) or hashes (number)
cfg.mp_models = {
  "mp_m_freemode_01",
  "mp_f_freemode_01"
}

-- customization set when spawning for the first time
-- see https://wiki.fivem.net/wiki/Peds
-- mp_m_freemode_01 (male)
-- mp_f_freemode_01 (female)
cfg.default_customization = {
  model = "mp_m_freemode_01" 
}

-- init default ped parts
for i=0,19 do
  cfg.default_customization["drawable:"..i] = {0,0}
end

return cfg
