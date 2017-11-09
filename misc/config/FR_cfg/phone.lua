
local cfg = {}

-- size of the sms history
cfg.sms_history = 15

-- maximum size of an sms
cfg.sms_size = 500

-- duration of a sms position marker (in seconds)
cfg.smspos_duration = 300

-- define phone services
-- blipid, blipcolor (customize alert blip)
-- alert_time (alert blip display duration in seconds)
-- alert_permission (permission required to receive the alert)
-- alert_notify (notification received when an alert is sent)
-- notify (notification when sending an alert)
cfg.services = {
  ["police"] = {
    blipid = 304,
    blipcolor = 38,
    alert_time = 300, -- 5 minutes
    alert_permission = "police.service",
    alert_notify = "~r~Police alerte:~n~~s~",
    notify = "~b~Vous avez appelé la police.",
    answer_notify = "~b~La police arrive."
  },
  ["emergency"] = {
    blipid = 153,
    blipcolor = 1,
    alert_time = 300, -- 5 minutes
    alert_permission = "emergency.service",
    alert_notify = "~r~Urgence alerte:~n~~s~",
    notify = "~b~Vous avez appelé les urgences.",
    answer_notify = "~b~Les urgences arrivent."
  },
  ["taxi"] = {
    blipid = 198,
    blipcolor = 5,
    alert_time = 300,
    alert_permission = "taxi.service",
    alert_notify = "~y~Taxi alerte:~n~~s~",
    notify = "~y~Vous avez appelé un taxi.",
    answer_notify = "~y~Un taxi arrive."
  }
}

-- define phone announces
-- image: background image for the announce (800x150 px)
-- price: amount to pay to post the announce
-- description (optional)
-- permission (optional): permission required to post the announce
cfg.announces = {
  ["admin"] = {
    --image = "nui://vrp_mod/announce_admin.png",
    image = "http://i.imgur.com/kjDVoI6.png",
    price = 0,
    description = "Admin seulement.",
    permission = "admin.announce"
  },
  ["police"] = {
    --image = "nui://vrp_mod/announce_police.png",
    image = "http://i.imgur.com/DY6DEeV.png",
    price = 0,
    description = "Seulement pour la police, ex: avis de recherche.",
    permission = "police.announce"
  },
  ["commercial"] = {
    --image = "nui://vrp_mod/announce_commercial.png",
    image = "http://i.imgur.com/b2O9WMa.png",
    description = "Annonce commerciales (travail, offres, demandes).",
    price = 5000
  },
  ["événement"] = {
    --image = "nui://vrp_mod/announce_party.png",
    image = "http://i.imgur.com/OaEnk64.png",
    description = "Organisation d'une fête ? Annoncer à tous le rendez-vous.",
    price = 5000
  }
}

return cfg
