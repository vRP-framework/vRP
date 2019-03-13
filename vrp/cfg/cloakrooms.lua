
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
---- map_entity: {ent,cfg} will fill cfg.title, cfg.pos
---- permissions (optional)
---- not_uniform (optional): if true, the cloakroom will take effect directly on the player, not as a uniform you can remove
cfg.cloakroom_types = {
  ["police"] = {
    _config = { permissions = {"police.cloakroom"}, map_entity = {"PoI", {marker_id = 1}} },
    ["Male uniform"] = {
      ["drawable:3"] = {30,0},
      ["drawable:4"] = {25,2},
      ["drawable:6"] = {24,0},
      ["drawable:8"] = {58,0},
      ["drawable:11"] = {55,0},
      ["prop:2"] = {2,0}
    },
    ["Female uniform"] = {
      ["drawable:3"] = {35,0},
      ["drawable:4"] = {30,0},
      ["drawable:6"] = {24,0},
      ["drawable:8"] = {6,0},
      ["drawable:11"] = {48,0},
      ["prop:2"] = {2,0}
    }
  },
  ["emergency"] = {
    _config = { permissions = {"emergency.cloakroom"}, map_entity = {"PoI", {marker_id = 1}} },
    ["Male uniform"] = {
      ["drawable:3"] = {81,0},
      ["drawable:4"] = {0,0},
      ["drawable:8"] = {15,0},
      ["drawable:6"] = {42,0},
      ["drawable:11"] = {26,0},
      ["prop:0"] = {6,1},
      ["prop:6"] = {12,1}
    }
  },
  ["jail"] = {
    _config = { map_entity = {"PoI", {marker_id = 1}} },
    ["Male suit"] = {
      ["drawable:3"] = {5,0},
      ["drawable:4"] = {7,15},
      ["drawable:8"] = {5,0},
      ["drawable:6"] = {12,6},
      ["drawable:11"] = {5,0}
    }
  },
  ["surgery"] = {
    _config = { not_uniform = true, map_entity = {"PoI", {marker_id = 1}} },
    ["Male"] = surgery_male,
    ["Female"] = surgery_female
  }
}

cfg.cloakrooms = {
  {"police", 454.324096679688,-991.499938964844,30.689577102661},
  {"emergency", -498.472290039063,-332.419097900391,34.5017356872559},
  {"jail",450.048889160156,-990.477600097656,30.6896018981934},
  {"surgery",-543.64965820313,-203.77143859863,38.215141296387}
}

return cfg
