
local cfg = {}

-- sanitize strings
-- {strchars, policy}
-- if policy is false, will discard the chars, if policy is true, will only allow the chars
--
-- /!\ NEVER ALLOW DOUBLE QUOTES, CAN CAUSE JSON HANG ISSUE

cfg.text = {"\"",false}
cfg.name = {"\"[]{}+=?!_()#@%0123456789/\\|",false}
cfg.business_name = {"\"[]{}+=?!_#",false}

return cfg
