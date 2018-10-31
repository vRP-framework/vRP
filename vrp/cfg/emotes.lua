
-- define emotes
-- use the custom emotes admin action to test emotes on-the-fly
-- animation list: http://docs.ragepluginhook.net/html/62951c37-a440-478c-b389-c471230ddfc5.htm

local cfg = {}

-- list of {title,upper,seq,looping,delay} and an optional permissions property
-- seq: can also be a task definition, check the examples below
-- delay: (optional) number of seconds before being able to do another emote, default is 0
cfg.emotes = {
  {"Handsup", -- handsup state, use clear to lower hands
    true,
    { -- sequence, list of {dict,name,loops}
      {"random@mugging3", "handsup_standing_base", 1}
    },
    true
    -- ,permissions = {"player.emote.handsup"}  -- you can add a permissions check
  },
  {"No", true, {{"gestures@f@standing@casual","gesture_head_no",1}}, false},
  {"Damn", true, {{"gestures@f@standing@casual","gesture_damn",1}}, false},
  {"Dance",
    false, {
      {"rcmnigel1bnmt_1b","dance_intro_tyler",1},
      {"rcmnigel1bnmt_1b","dance_loop_tyler",1}
    }, false
  },
  {"Salute", true,{{"mp_player_int_uppersalute","mp_player_int_salute",1}},false},
  {"Rock", true,{{"mp_player_introck","mp_player_int_rock",1}},false},
  {"Sit Chair", false, {task="PROP_HUMAN_SEAT_CHAIR_MP_PLAYER"}, false},
--  {"Cop", false, {task="WORLD_HUMAN_COP_IDLES"}, false},
  {"Bum sign", false, {task="WORLD_HUMAN_BUM_FREEWAY"}, false, 5},
  {"Bum wash", false, {task="WORLD_HUMAN_BUM_WASH"}, false},
  {"Clipboard", false, {task="WORLD_HUMAN_CLIPBOARD"}, false, 5},
  {"Binoculars",false, {task="WORLD_HUMAN_BINOCULARS"}, false},
  {"Cheer",false, {task="WORLD_HUMAN_CHEERING"}, false},
  {"Crink",false, {task="WORLD_HUMAN_DRINKING"}, false},
  {"Smoke", false, {task="WORLD_HUMAN_SMOKING"}, false},
  {"Smoke nervous", false, {task="WORLD_HUMAN_AA_SMOKE"}, false, 5},
--  {"Film", false, {task="WORLD_HUMAN_MOBILE_FILM_SHOCKING"}, false},
--  {"Plant", false, {task="WORLD_HUMAN_GARDENER_PLANT"}, false},
  {"Guard", false, {task="WORLD_HUMAN_GUARD_STAND"}, false},
--  {"Hammer", false, {task="WORLD_HUMAN_HAMMERING"}, false},
--  {"Drill", false, {task="WORLD_HUMAN_CONST_DRILL"}, false},
--  {"Leaf blow", false, {task="WORLD_HUMAN_GARDENER_LEAF_BLOWER"}, false},
--  {"Fishing", false, {task="WORLD_HUMAN_STAND_FISHING"}, false},
--  {"Hangout", false, {task="WORLD_HUMAN_HANG_OUT_STREET"}, false},
-- {"Hiker", false, {task="WORLD_HUMAN_HIKER_STANDING"}, false},
  {"Partying", false, {task="WORLD_HUMAN_PARTYING"}, false, 5},
  {"Statue", false, {task="WORLD_HUMAN_HUMAN_STATUE"}, false},
  {"Music", false, {task="WORLD_HUMAN_MUSICIAN"}, false, 5},
  {"Jog", false, {task="WORLD_HUMAN_JOG_STANDING"}, false},
  {"Lean", false, {task="WORLD_HUMAN_LEANING"}, false},
  {"Flex", false, {task="WORLD_HUMAN_MUSCLE_FLEX"}, false},
  {"Camera", false, {task="WORLD_HUMAN_PAPARAZZI"}, false},
  {"Sit", false, {task="WORLD_HUMAN_PICNIC"}, false},
  {"Hoe", false, {task="WORLD_HUMAN_PROSTITUTE_HIGH_CLASS"}, false},
  {"Hoe2", false, {task="WORLD_HUMAN_PROSTITUTE_LOW_CLASS"}, false},
  {"Pushups", false, {task="WORLD_HUMAN_PUSH_UPS"}, false},
  {"Situps", false, {task="WORLD_HUMAN_SIT_UPS"}, false},
--  {"Fish", false, {task="WORLD_HUMAN_STAND_FISHING"}, false},
--  {"Impatient", false, {task="WORLD_HUMAN_STAND_IMPATIENT"}, false},
  {"Mobile", false, {task="WORLD_HUMAN_STAND_MOBILE"}, false},
  {"Diggit", false, {task="WORLD_HUMAN_STRIP_WATCH_STAND"}, false},
  {"Sunbath", false, {task="WORLD_HUMAN_SUNBATHE_BACK"}, false},
  {"Sunbath2", false, {task="WORLD_HUMAN_SUNBATHE"}, false},
--  {"Weld", false, {task="WORLD_HUMAN_WELDING"}, false},
--  {"Kneel", false, {task="CODE_HUMAN_MEDIC_KNEEL"}, false},
--  {"Crowdcontrol", false, {task="CODE_HUMAN_POLICE_CROWD_CONTROL"}, false},
--  {"Investigate", false, {task="CODE_HUMAN_POLICE_INVESTIGATE"}, false},
  {"Yoga", false, {task="WORLD_HUMAN_YOGA"}, false}
}

return cfg
