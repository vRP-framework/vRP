
local Audio = class("Audio", vRP.Extension)

function Audio:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/audio")

  self.reg_channels = {} -- map of id => config

  self:registerVoiceChannel("world", self.cfg.world_voice)
end

-- register VoIP channel
-- all channels should be registered before any player joins the server
--
-- id: channel name/id (string)
-- config:
--- effects: map of name => true/options
---- spatialization => { max_dist: ..., rolloff: ..., dist_model: ... } (per peer effect)
---- biquad => { frequency: ..., Q: ..., type: ..., detune: ..., gain: ...} see WebAudioAPI BiquadFilter
----- freq = 1700, Q = 3, type = "bandpass" (idea for radio effect)
---- gain => { gain: ... }
function Audio:registerVoiceChannel(id, config)
  if not self.reg_channels[id] then
    self.reg_channels[id] = config
  else
    self:error("voice channel \""..id.."\" already registered")
  end
end

-- build channels if not built, return map of name => id
-- return map of id => {index, config}
function Audio:getChannels()
  if not self.channels then
    self.channels = {}

    local list = {}

    for id, config in pairs(self.reg_channels) do
      table.insert(list, {id, config})
    end

    table.sort(list, function(a,b) return a[1] < b[1] end)

    for idx, el in ipairs(list) do
      self.channels[el[1]] = {idx, el[2]}
    end
  end

  return self.channels
end

-- EVENT
Audio.event = {}

function Audio.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- connect VoIP
    self.remote._configureVoIP(user.source, {server = self.cfg.voip_server, channels = self:getChannels()}, self.cfg.vrp_voip, self.cfg.voip_interval, self.cfg.voip_proximity)
  end
end

vRP:registerExtension(Audio)
