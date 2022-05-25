
local cfg = {}

-- mysql credentials
cfg.db = {
  driver = "oxmysql",
  host = "127.0.0.1",
  database = "vRP",
  user = "vRP",
  password = "password"
}

cfg.server_id = "main" -- identify the server (ex: in database)

cfg.save_interval = 60 -- seconds

-- delay the tunnel at loading (for weak connections)
cfg.load_duration = 30 -- seconds, player duration in loading mode at the first spawn
cfg.load_delay = 60 -- milliseconds, delay the tunnel communication when in loading mode
cfg.global_delay = 0 -- milliseconds, delay the tunnel communication when not in loading mode

cfg.max_characters = 5 -- maximum number of characters per user
cfg.character_select_delay = 60 -- minimum number of seconds between character selects, at least 30 seconds is recommended

-- If enabled, will not use the IP address to identify players (recommended, solve same IP issue; other identifiers should be available).
cfg.ignore_ip_identifier = true

cfg.lang = "en"

cfg.log_level = 0 -- maximum verbose level for logs, -1 may disable logs and 1000 may print all logs

return cfg
