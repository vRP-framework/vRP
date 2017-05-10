
local cfg = {}

-- minimum capital to open a business
cfg.minimum_capital = 25000

-- capital transfer reset interval in minutes
-- default: reset every 24h
cfg.transfer_reset_interval = 24*60

-- commerce chamber {blipid,blipcolor}
cfg.blip = {431,70} 

-- positions of commerce chambers
cfg.commerce_chambers = {
  {1858.21, 3687.51, 34.2671}
}

return cfg
