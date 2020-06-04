-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.audio then return end

local Audio = class("Audio", vRP.Extension)

-- METHODS

function Audio:__construct()
  vRP.Extension.__construct(self)

  self.channel_callbacks = {}
  self.voice_channels = {} -- map of channel => map of player => state (0-1)

  self.vrp_voip = false
  self.voip_interval = 5000
  self.voip_proximity = 100 

  self.active_channels = {}

  self.speaking = false

  -- listener task
  self.listener_wait = math.ceil(1/vRP.cfg.audio_listener_rate*1000)

  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(self.listener_wait)

      local x,y,z
      if vRP.cfg.audio_listener_on_player then
        local ped = GetPlayerPed(PlayerId())
        x,y,z = table.unpack(GetPedBoneCoords(ped, 31086, 0,0,0)) -- head pos
      else
        x,y,z = table.unpack(GetGameplayCamCoord())
      end

      local fx,fy,fz = vRP.EXT.Base:getCamDirection()
      SendNUIMessage({act="audio_listener", x = x, y = y, z = z, fx = fx, fy = fy, fz = fz})
    end
  end)

  -- task: detect players near, give positions to AudioEngine
  Citizen.CreateThread(function()
    local n = 0
    local ns = math.ceil(self.voip_interval/self.listener_wait) -- connect/disconnect every x milliseconds
    local connections = {}

    while true do
      Citizen.Wait(self.listener_wait)

      n = n+1
      local voip_check = (n >= ns)
      if voip_check then n = 0 end

      local pid = PlayerId()
      local spid = GetPlayerServerId(pid)
      local px,py,pz = vRP.EXT.Base:getPosition()

      local positions = {}

      local players = vRP.EXT.Base.players
      for k,v in pairs(players) do
        local player = GetPlayerFromServerId(k)

        if NetworkIsPlayerConnected(player) or player == pid then
          local oped = GetPlayerPed(player)
          local x,y,z = table.unpack(GetPedBoneCoords(oped, 31086, 0,0,0)) -- head pos
          positions[k] = {x,y,z} -- add position

          if player ~= pid and self.vrp_voip and voip_check then -- vRP voip detection/connection
            local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
            local in_radius = (distance <= self.voip_proximity)
            if not connections[k] and in_radius then -- join radius
              self:connectVoice("world", k)
              connections[k] = true
            elseif connections[k] and not in_radius then -- leave radius
              self:disconnectVoice("world", k)
              connections[k] = nil
            end
          end
        end
      end

      positions._ = true -- prevent JS array type
      SendNUIMessage({act="set_player_positions", positions=positions})
    end
  end)

  -- task: voice controls 
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)

      -- voip/speaking
      local old_speaking = self.speaking
      self.speaking = IsControlPressed(1,249)

      if old_speaking ~= self.speaking then -- change
        if not self.speaking then -- delay off
          self.speaking = true
          SetTimeout(vRP.cfg.push_to_talk_end_delay+1, function()
            if self.speaking_time and GetGameTimer()-self.speaking_time >= vRP.cfg.push_to_talk_end_delay then
              self.speaking = false
              vRP:triggerEvent("speakingChange", self.speaking)
              self.speaking_time = nil
            end
          end)
        else -- instantaneous
          vRP:triggerEvent("speakingChange", self.speaking)
          self.speaking_time = GetGameTimer()
        end
      end
    end
  end)

  -- task: voice proximity
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(500)
      if self.vrp_voip then -- vRP voip
        NetworkSetTalkerProximity(self.voip_proximity) -- disable voice chat
      else -- regular voice chat
        local ped = GetPlayerPed(-1)
        local proximity = vRP.cfg.voice_proximity

        if IsPedSittingInAnyVehicle(ped) then
          local veh = GetVehiclePedIsIn(ped,false)
          local hash = GetEntityModel(veh)
          -- make open vehicles (bike,etc) use the default proximity
          if IsThisModelACar(hash) or IsThisModelAHeli(hash) or IsThisModelAPlane(hash) then
            proximity = vRP.cfg.voice_proximity_vehicle
          end
        elseif vRP.EXT.Base:isInside() then
          proximity = vRP.cfg.voice_proximity_inside
        end

        NetworkSetTalkerProximity(proximity+0.0001)
      end
    end
  end)
end

-- play audio source (once)
--- url: valid audio HTML url (ex: .ogg/.wav/direct ogg-stream url)
--- volume: 0-1 
--- x,y,z: position (omit for unspatialized)
--- max_dist  (omit for unspatialized)
--- player: (optional) player source id, if passed the spatialized source will be relative to the player (parented)
function Audio:playAudioSource(url, volume, x, y, z, max_dist, player)
  SendNUIMessage({act="play_audio_source", url = url, x = x, y = y, z = z, volume = volume, max_dist = max_dist, player = player})
end

-- set named audio source (looping)
--- name: source name
--- url: valid audio HTML url (ex: .ogg/.wav/direct ogg-stream url)
--- volume: 0-1 
--- x,y,z: position (omit for unspatialized)
--- max_dist  (omit for unspatialized)
--- player: (optional) player source id, if passed the spatialized source will be relative to the player (parented)
function Audio:setAudioSource(name, url, volume, x, y, z, max_dist, player)
  SendNUIMessage({act="set_audio_source", name = name, url = url, x = x, y = y, z = z, volume = volume, max_dist = max_dist, player = player})
end

-- remove named audio source
function Audio:removeAudioSource(name)
  SendNUIMessage({act="remove_audio_source", name = name})
end

-- VoIP

-- create connection to another player for a specific channel
function Audio:connectVoice(channel, player)
  SendNUIMessage({act="connect_voice", channel=channel, player=player})
end

-- delete connection to another player for a specific channel
-- player: nil to disconnect from all players
function Audio:disconnectVoice(channel, player)
  SendNUIMessage({act="disconnect_voice", channel=channel, player=player})
end

-- enable/disable speaking for a specific channel
--- active: true/false 
function Audio:setVoiceState(channel, active)
  SendNUIMessage({act="set_voice_state", channel=channel, active=active})
end

function Audio:isSpeaking()
  return self.speaking
end

-- EVENT
Audio.event = {}

function Audio.event:speakingChange(speaking)
  -- voip
  if self.vrp_voip then
    self:setVoiceState("world", speaking)
  end
end

function Audio.event:voiceChannelTransmittingChange(channel, transmitting)
  local old_state = (next(self.active_channels) ~= nil)

  if transmitting then
    self.active_channels[channel] = true
  else
    self.active_channels[channel] = nil
  end

  local state = next(self.active_channels) ~= nil
  if old_state ~= state then -- update indicator/local player talking
    SendNUIMessage({act="set_voice_indicator", state = state})
    SetPlayerTalkingOverride(PlayerId(), state)
  end
end

function Audio.event:voiceChannelPlayerSpeakingChange(channel, player, speaking)
  if channel == "world" then -- remote player talking
    SetPlayerTalkingOverride(GetPlayerFromServerId(player), speaking)
  end
end

-- TUNNEL
Audio.tunnel = {}

function Audio.tunnel:configureVoIP(config, vrp_voip, interval, proximity)
  self.vrp_voip = vrp_voip
  self.voip_interval = interval
  self.voip_proximity = proximity

  if self.vrp_voip then
    NetworkSetVoiceChannel(config.id)
  end

  SendNUIMessage({act="configure_voip", config = config})
end

Audio.tunnel.playAudioSource = Audio.playAudioSource
Audio.tunnel.setAudioSource = Audio.setAudioSource
Audio.tunnel.removeAudioSource = Audio.removeAudioSource
Audio.tunnel.connectVoice = Audio.connectVoice
Audio.tunnel.disconnectVoice = Audio.disconnectVoice
Audio.tunnel.setVoiceState = Audio.setVoiceState

-- NUI

RegisterNUICallback("audio",function(data,cb)
  if data.act == "voice_channel_player_speaking_change" then
    vRP:triggerEvent("voiceChannelPlayerSpeakingChange", data.channel, tonumber(data.player), data.speaking)
  elseif data.act == "voice_channel_transmitting_change" then
    vRP:triggerEvent("voiceChannelTransmittingChange", data.channel, data.transmitting)
  end
end)

vRP:registerExtension(Audio)
