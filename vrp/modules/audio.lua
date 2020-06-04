-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.audio then return end

local Audio = class("Audio", vRP.Extension)
local lang = vRP.lang

-- PRIVATE METHODS

-- menu: admin
local function menu_admin(self)
  local function m_audiosource(menu)
    local user = menu.user

    local infos = splitString(user:prompt(lang.admin.custom_audiosource.prompt(), ""), "=")
    local name = infos[1]
    local url = infos[2]

    if name and string.len(name) > 0 then
      if url and string.len(url) > 0 then
        local x,y,z = vRP.EXT.Base.remote.getPosition(user.source)
        vRP.EXT.Audio.remote._setAudioSource(-1,"vRP:admin:"..name,url,0.5,x,y,z,125)
      else
        vRP.EXT.Audio.remote._removeAudioSource(-1,"vRP:admin:"..name)
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    local user = menu.user

    if user:hasPermission("player.custom_sound") then
      menu:addOption(lang.admin.custom_audiosource.title(), m_audiosource)
    end
  end)
end

-- METHODS

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
---- spatialization => { max_dist: ..., rolloff: ..., dist_model: ..., ref_dist: ...} (per peer effect)
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
    self.remote._configureVoIP(user.source, {bitrate = self.cfg.voip_bitrate, frame_size = self.cfg.voip_frame_size, server = self.cfg.voip_server, channels = self:getChannels(), id = user.source}, self.cfg.vrp_voip, self.cfg.voip_interval, self.cfg.voip_proximity)
  end
end

function Audio.event:extensionLoad(ext)
  if ext == vRP.EXT.Admin then
    menu_admin(self)
  end
end

vRP:registerExtension(Audio)
