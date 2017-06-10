
-- this file configure the cloakrooms on the map

local cfg = {}

-- prepare surgeries customizations
local surgery_male = { model = "mp_m_freemode_01" }
local surgery_female = { model = "mp_f_freemode_01" }

for i=0,19 do
  surgery_female[i] = {0,0}
  surgery_male[i] = {0,0}
end

-- cloakroom types (_config, map of name => customization)
--- _config:
---- permission (optional)
---- not_uniform (optional): if true, the cloakroom will take effect directly on the player, not as a uniform you can remove
cfg.cloakroom_types = {
  ["police"] = {
    _config = { permission = "police.cloakroom" },
    ["Uniform"] = {
      [3] = {30,0},
      [4] = {25,2},
      [6] = {24,0},
      [8] = {58,0},
      [11] = {55,0},
      ["p2"] = {2,0}
    }
  },
  ["surgery"] = {
    _config = { permission = "police.cloakroom", not_uniform = true },
    ["Male"] = surgery_male,
    ["Female"] = surgery_female
  }
}

cfg.cloakrooms = {
  {"police", 1848.21, 3688.51, 34.2671},
  {"surgery",1849.7425,3686.5759,34.2670}
}

return cfg
