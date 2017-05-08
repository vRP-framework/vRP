
-- define emotes
-- use the custom emotes admin action to test emotes on-the-fly
-- animation list: http://docs.ragepluginhook.net/html/62951c37-a440-478c-b389-c471230ddfc5.htm

local cfg = {}

-- map of emote_name => {upper,seq,looping}
cfg.emotes = {
  ["Handsup"] = { -- handsup state, use clear to lower hands
    true,
    { -- sequence, list of {dict,name,loops}
      {"random@mugging3", "handsup_standing_base", 1}
    },
    true
  },
  ["No"] = {
    true, {{"gestures@f@standing@casual","gesture_head_no",1}}, false
  },
  ["Damn"] = {
    true, {{"gestures@f@standing@casual","gesture_damn",1}}, false
  },
  ["Dance"] = {
    false, {
      {"rcmnigel1bnmt_1b","dance_intro_tyler",1},
      {"rcmnigel1bnmt_1b","dance_loop_tyler",1}
    }, false
  },
  ["Salute"] = {true,{{"mp_player_int_uppersalute","mp_player_int_salute",1}},false},
  ["Rock"] = {true,{{"mp_player_introck","mp_player_int_rock",1}},false}
}

return cfg
