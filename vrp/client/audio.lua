
local Audio = class("Audio", vRP.Extension)

-- METHODS

function Audio:__construct()
  vRP.Extension.__construct(self)

  self.channel_callbacks = {}
  self.voice_channels = {} -- map of channel => map of player => state (0-1)

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

  if vRP.cfg.vrp_voip then -- setup voip world channel
    -- world channel behavior
    self:registerVoiceCallbacks("world", function(player)
      self:log("(vRPvoice-world) requested by "..player)

      -- check connection distance

      local pid = PlayerId()
      local px,py,pz = vRP.EXT.Base:getPosition()

      local cplayer = GetPlayerFromServerId(player)

      if NetworkIsPlayerConnected(cplayer) then
        local oped = GetPlayerPed(cplayer)
        local x,y,z = table.unpack(GetEntityCoords(oped,true))

        local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
        return (distance <= cfg.voip_proximity*1.5) -- valid connection
      end
    end,
    function(player, is_origin)
      self:log("(vRPvoice-world) connected to "..player)
      self:setVoiceState("world", nil, self.speaking)
    end,
    function(player)
      self:log("(vRPvoice-world) disconnected from "..player)
    end)

  end

  -- task: detect players near, give positions to AudioEngine
  Citizen.CreateThread(function()
    local n = 0
    local ns = math.ceil(vRP.cfg.voip_interval/self.listener_wait) -- connect/disconnect every x milliseconds

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

        if player ~= pid and NetworkIsPlayerConnected(player) then
          local oped = GetPlayerPed(player)
          local x,y,z = table.unpack(GetPedBoneCoords(oped, 31086, 0,0,0)) -- head pos
          positions[k] = {x,y,z} -- add position

          if vRP.cfg.vrp_voip and voip_check then -- vRP voip detection/connection
            local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
            local in_radius = (distance <= cfg.voip_proximity)
            local linked = self:isVoiceConnected("world", k)
            local initiator = (spid < k)
            if in_radius and not linked and initiator then -- join radius
              self:connectVoice("world", k)
            elseif not in_radius and linked then -- leave radius
              self:disconnectVoice("world", k)
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

      if old_speaking ~= self.speaking then
        vRP:triggerEvent("speakingChange", self.speaking)
      end
    end
  end)

  -- task: voice proximity
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(500)
      if vRP.cfg.vrp_voip then -- vRP voip
        NetworkSetTalkerProximity(0) -- disable voice chat
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
function Audio:playAudioSource(url, volume, x, y, z, max_dist)
  SendNUIMessage({act="play_audio_source", url = url, x = x, y = y, z = z, volume = volume, max_dist = max_dist})
end

-- set named audio source (looping)
--- name: source name
--- url: valid audio HTML url (ex: .ogg/.wav/direct ogg-stream url)
--- volume: 0-1 
--- x,y,z: position (omit for unspatialized)
--- max_dist  (omit for unspatialized)
function Audio:setAudioSource(name, url, volume, x, y, z, max_dist)
  SendNUIMessage({act="set_audio_source", name = name, url = url, x = x, y = y, z = z, volume = volume, max_dist = max_dist})
end

-- remove named audio source
function Audio:removeAudioSource(name)
  SendNUIMessage({act="remove_audio_source", name = name})
end

-- VoIP

function Audio:setPeerConfiguration(config)
  SendNUIMessage({act="set_peer_configuration", config=config})
end

-- request connection to another player for a specific channel
function Audio:connectVoice(channel, player)
  -- register channel/player
  local _channel = self.voice_channels[channel]
  if not _channel then
    _channel = {}
    self.voice_channels[channel] = _channel
  end

  if _channel[player] == nil then -- check if not already connecting/connected
    SendNUIMessage({act="connect_voice", channel=channel, player=player})
  end
end

-- disconnect from another player for a specific channel
-- player: nil to disconnect from all players
function Audio:disconnectVoice(channel, player)
  SendNUIMessage({act="disconnect_voice", channel=channel, player=player})
end

-- register callbacks for a specific channel
--- on_offer(player): should return true to accept the connection
--- on_connect(player, is_origin): is_origin is true if it's the local peer (not an answer)
--- on_disconnect(player)
function Audio:registerVoiceCallbacks(channel, on_offer, on_connect, on_disconnect)
  if not self.channel_callbacks[channel] then
    self.channel_callbacks[channel] = {on_offer, on_connect, on_disconnect}
  else
    self:log("[vRP] VoIP channel callbacks for <"..channel.."> already registered.")
  end
end

-- check if there is an active connection
-- return boolean or nil
function Audio:isVoiceConnected(channel, player)
  local channel = self.voice_channels[channel]
  if channel then
    return channel[player] == 1
  end
end

-- check if there is a pending connection
-- return boolean or nil
function Audio:isVoiceConnecting(channel, player)
  local channel = self.voice_channels[channel]
  if channel then
    return channel[player] == 0
  end
end

-- enable/disable speaking
--- player: nil to affect all channel peers
--- active: true/false 
function Audio:setVoiceState(channel, player, active)
  SendNUIMessage({act="set_voice_state", channel=channel, player=player, active=active})
end

-- configure channel (can only be called once per channel)
--- config:
---- effects: map of name => true/options
----- spatialization => { max_dist: ..., rolloff: ..., dist_model: ... } (per peer effect)
----- biquad => { frequency: ..., Q: ..., type: ..., detune: ..., gain: ...} see WebAudioAPI BiquadFilter
------ freq = 1700, Q = 3, type = "bandpass" (idea for radio effect)
----- gain => { gain: ... }
function Audio:configureVoice(channel, config)
  SendNUIMessage({act="configure_voice", channel=channel, config=config})
end

-- receive voice peer signal
function Audio:signalVoicePeer(player, data)
  if data.sdp_offer then -- check offer
    -- register channel/player
    local channel = self.voice_channels[data.channel]
    if not channel then
      channel = {}
      self.voice_channels[data.channel] = channel
    end

    if channel[player] == nil then -- check if not already connecting
      local cbs = self.channel_callbacks[data.channel]
      if cbs then
        local cb = cbs[1]
        if cb and cb(player) then
          channel[player] = 0 -- wait connection
          SendNUIMessage({act="voice_peer_signal", player=player, data=data})
        end
      end
    end
  else -- other signal
    SendNUIMessage({act="voice_peer_signal", player=player, data=data})
  end
end

function Audio:isSpeaking()
  return self.speaking
end

-- EVENT
Audio.event = {}

function Audio.event:speakingChange(speaking)
  -- voip
  if vRP.cfg.vrp_voip then
    self:setVoiceState("world", nil, speaking)
  end
end

function Audio.event:NUIready()
  if vRP.cfg.vrp_voip then
    -- world channel config
    self:configureVoice("world", vRP.cfg.world_voice_config)
  end
end

-- TUNNEL
Audio.tunnel = {}

Audio.tunnel.setPeerConfiguration = Audio.setPeerConfiguration
Audio.tunnel.signalVoicePeer = Audio.signalVoicePeer
Audio.tunnel.playAudioSource = Audio.playAudioSource
Audio.tunnel.setAudioSource = Audio.setAudioSource
Audio.tunnel.removeAudioSource = Audio.removeAudioSource

-- NUI

-- VoIP

RegisterNUICallback("audio",function(data,cb)
  if data.act == "voice_connected" then
    -- register channel/player
    local channel = vRP.EXT.Audio.voice_channels[data.channel]
    if not channel then
      channel = {}
      vRP.EXT.Audio.voice_channels[data.channel] = channel
    end
    channel[data.player] = 1 -- connected

    -- callback
    local cbs = vRP.EXT.Audio.channel_callbacks[data.channel]
    if cbs then
      local cb = cbs[2]
      if cb then cb(data.player, data.origin) end
    end
  elseif data.act == "voice_disconnected" then
    -- unregister channel/player
    local channel = vRP.EXT.Audio.voice_channels[data.channel]
    if channel then
      channel[data.player] = nil
    end

    -- callback
    local cbs = vRP.EXT.Audio.channel_callbacks[data.channel]
    if cbs then
      local cb = cbs[3]
      if cb then cb(data.player) end
    end
  elseif data.act == "voice_peer_signal" then
    vRP.EXT.Audio.remote._signalVoicePeer(data.player, data.data)
  end
end)

vRP:registerExtension(Audio)
