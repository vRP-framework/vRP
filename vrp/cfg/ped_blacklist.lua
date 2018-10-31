
local cfg = {}

cfg.remove_interval = 1500 -- number of milliseconds between two remove check

-- Ped model blacklist, names (string) or hashes (number)
cfg.ped_models = {
  -- cops
  "s_f_y_cop_01",
  "s_m_y_cop_01",
  "s_m_y_hwaycop_01",
  "csb_cop"
}

return cfg
