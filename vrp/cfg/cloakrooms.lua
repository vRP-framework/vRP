
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
---- permissions (optional)
---- not_uniform (optional): if true, the cloakroom will take effect directly on the player, not as a uniform you can remove
cfg.cloakroom_types = {
  ["police"] = {
    _config = { permissions = {"police.cloakroom"} },
    ["Male uniform"] = {
      [3] = {30,0},
      [4] = {25,2},
      [6] = {24,0},
      [8] = {58,0},
      [11] = {55,0},
      ["p2"] = {2,0}
    },
    ["Female uniform"] = {
      [3] = {35,0},
      [4] = {30,0},
      [6] = {24,0},
      [8] = {6,0},
      [11] = {48,0},
      ["p2"] = {2,0}
    }
  },
  ["emergency"] = {
    _config = { permissions = {"emergency.cloakroom"} },
    ["Male uniform"] = {
      [3] = {81,0},
      [4] = {0,0},
      [8] = {15,0},
      [6] = {42,0},
      [11] = {26,0},
      ["p0"] = {6,1},
      ["p6"] = {12,1}
    }
  },
  ["jail"] = {
    ["Male suit"] = {
      [3] = {5,0},
      [4] = {7,15},
      [8] = {5,0},
      [6] = {12,6},
      [11] = {5,0}
    }
  },
  ["surgery"] = {
    _config = { not_uniform = true },
    ["Male"] = surgery_male,
    ["Female"] = surgery_female
  }
}

cfg.cloakrooms = {
  {"police", 454.324096679688,-991.499938964844,30.689577102661},
  {"emergency", -498.472290039063,-332.419097900391,34.5017356872559},
  {"jail",450.048889160156,-990.477600097656,30.6896018981934},
  {"surgery",1849.7425,3686.5759,34.2670}
}

return cfg
