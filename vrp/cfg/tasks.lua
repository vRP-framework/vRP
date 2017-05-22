
-- define tasks

local cfg = {}

-- map of task_name => {name,anim}
cfg.tasks = {
    ["sitchair"] = {"sitchair", "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER"},
    ["cop"] = {"cop", "WORLD_HUMAN_COP_IDLES"},
    ["binoculars"] = {"binoculars", "WORLD_HUMAN_BINOCULARS"},
    ["cheer"] = {"cheer", "WORLD_HUMAN_CHEERING"},
    ["drink"] = {"drink", "WORLD_HUMAN_DRINKING"},
    ["smoke"] = {"smoke", "WORLD_HUMAN_SMOKING"},
    ["film"] = {"film", "WORLD_HUMAN_MOBILE_FILM_SHOCKING"},
    ["plant"] = {"plant","WORLD_HUMAN_GARDENER_PLANT"},
    ["guard"] = {"guard", "WORLD_HUMAN_GUARD_STAND"},
    ["hammer"] = {"hammer", "WORLD_HUMAN_HAMMERING"},
    ["hangout"] = {"hangout", "WORLD_HUMAN_HANG_OUT_STREET"},
    ["hiker"] = {"hiker", "WORLD_HUMAN_HIKER_STANDING"},
    ["statue"] = {"statue", "WORLD_HUMAN_HUMAN_STATUE"},
    ["jog"] = {"jog", "WORLD_HUMAN_JOG_STANDING"},
    ["lean"] = {"lean", "WORLD_HUMAN_LEANING"},
    ["flex"] = {"flex", "WORLD_HUMAN_MUSCLE_FLEX"},
    ["camera"] = {"camera", "WORLD_HUMAN_PAPARAZZI"},
    ["sit"] = {"sit", "WORLD_HUMAN_PICNIC"},
    ["hoe"] = {"hoe", "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS"},
    ["hoe2"] = {"hoe2", "WORLD_HUMAN_PROSTITUTE_LOW_CLASS"},
    ["pushups"] = {"pushups", "WORLD_HUMAN_PUSH_UPS"},
    ["situps"] = {"situps", "WORLD_HUMAN_SIT_UPS"},
    ["fish"] = {"fish", "WORLD_HUMAN_STAND_FISHING"},
    ["impatient"] = {"impatient", "WORLD_HUMAN_STAND_IMPATIENT"},
    ["mobile"] = {"mobile", "WORLD_HUMAN_STAND_MOBILE"},
    ["diggit"] = {"diggit", "WORLD_HUMAN_STRIP_WATCH_STAND"},
    ["sunbath"] = {"sunbath", "WORLD_HUMAN_SUNBATHE_BACK"},
    ["sunbath2"] = {"sunbath2", "WORLD_HUMAN_SUNBATHE"},
    ["weld"] = {"weld", "WORLD_HUMAN_WELDING"},
    ["yoga"] = {"yoga", "WORLD_HUMAN_YOGA"},
    ["kneel"] = {"kneel", "CODE_HUMAN_MEDIC_KNEEL"},
    ["crowdcontrol"] = {"crowdcontrol", "CODE_HUMAN_POLICE_CROWD_CONTROL"},
    ["investigate"] = {"investigate", "CODE_HUMAN_POLICE_INVESTIGATE"}
}

return cfg