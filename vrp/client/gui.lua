
local GUI = class("GUI", vRP.Extension)

function GUI:__construct()
  vRP.Extension.__construct(self)

  self.menu_state = {}

  self.channel_callbacks = {}
  self.voice_channels = {} -- map of channel => map of player => state (0-1)

  self.speaking = false

  self.paused = false

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
      print("(vRPvoice-world) requested by "..player)

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
      print("(vRPvoice-world) connected to "..player)
      self:setVoiceState("world", nil, self.speaking)
    end,
    function(player)
      print("(vRPvoice-world) disconnected from "..player)
    end)

    AddEventHandler("vRP:NUIready", function()
      -- world channel config
      self:configureVoice("world", vRP.cfg.world_voice_config)
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

  -- task: gui controls (from cellphone)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      -- menu controls
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.up)) then SendNUIMessage({act="event",event="UP"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.down)) then SendNUIMessage({act="event",event="DOWN"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.left)) then SendNUIMessage({act="event",event="LEFT"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.right)) then SendNUIMessage({act="event",event="RIGHT"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.select)) then SendNUIMessage({act="event",event="SELECT"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.cancel)) then 
        self.remote._closeMenu()
        SendNUIMessage({act="event",event="CANCEL"}) 
      end

      -- open general menu
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.phone.open)) and ((vRP.EXT.PlayerState and not vRP.EXT.PlayerState:isInComa() or true) or not vRP.cfg.coma_disable_menu) and ((vRP.EXT.Police and not vRP.EXT.Police:isHandcuffed() or true) or not vRP.cfg.handcuff_disable_menu) and not self.menu_state.opened then 
        self.remote._openMainMenu() 
      end

      -- F5,F6 (default: control michael, control franklin)
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.request.yes)) then SendNUIMessage({act="event",event="F5"}) end
      if IsControlJustPressed(table.unpack(vRP.cfg.controls.request.no)) then SendNUIMessage({act="event",event="F6"}) end

      -- pause events
      local pause_menu = IsPauseMenuActive()
      if pause_menu and not self.paused then
        self.paused = true
        vRP:triggerEvent("pauseChange", self.paused)
      elseif not pause_menu and paused then
        self.paused = false
        vRP:triggerEvent("pauseChange", self.paused)
      end

      -- voip/speaking
      local old_speaking = self.speaking
      self.speaking = IsControlPressed(1,249)

      -- voip
      if vRP.cfg.vrp_voip then
        if old_speaking ~= self.speaking then
          self:setVoiceState("world", nil, self.speaking)
        end
      end
    end
  end)
end

-- CONTROLS/GUI

function GUI:isPaused()
  return self.paused
end

-- ANNOUNCE

-- add an announce to the queue
-- background: image url (800x150)
-- content: announce html content
function GUI:announce(background,content)
  SendNUIMessage({act="announce",background=background,content=content})
end

-- PROGRESS BAR

-- create/update a progress bar
function GUI:setProgressBar(name,anchor,text,r,g,b,value)
  local pbar = {name=name,anchor=anchor,text=text,r=r,g=g,b=b,value=value}

  -- default values
  if pbar.value == nil then pbar.value = 0 end

  SendNUIMessage({act="set_pbar",pbar = pbar})
end

-- set progress bar value in percent
function GUI:setProgressBarValue(name,value)
  SendNUIMessage({act="set_pbar_val", name = name, value = value})
end

-- set progress bar text
function GUI:setProgressBarText(name,text)
  SendNUIMessage({act="set_pbar_text", name = name, text = text})
end

-- remove a progress bar
function GUI:removeProgressBar(name)
  SendNUIMessage({act="remove_pbar", name = name})
end

-- DIV

-- set a div
-- css: plain global css, the div class is "div_name"
-- content: html content of the div
function GUI:setDiv(name,css,content)
  SendNUIMessage({act="set_div", name = name, css = css, content = content})
end

-- set the div css
function GUI:setDivCss(name,css)
  SendNUIMessage({act="set_div_css", name = name, css = css})
end

-- set the div content
function GUI:setDivContent(name,content)
  SendNUIMessage({act="set_div_content", name = name, content = content})
end

-- execute js for the div
-- js variables: this is the div
function GUI:divExecuteJS(name,js)
  SendNUIMessage({act="div_execjs", name = name, js = js})
end

-- remove the div
function GUI:removeDiv(name)
  SendNUIMessage({act="remove_div", name = name})
end

-- AUDIO

-- play audio source (once)
--- url: valid audio HTML url (ex: .ogg/.wav/direct ogg-stream url)
--- volume: 0-1 
--- x,y,z: position (omit for unspatialized)
--- max_dist  (omit for unspatialized)
function GUI:playAudioSource(url, volume, x, y, z, max_dist)
  SendNUIMessage({act="play_audio_source", url = url, x = x, y = y, z = z, volume = volume, max_dist = max_dist})
end

-- set named audio source (looping)
--- name: source name
--- url: valid audio HTML url (ex: .ogg/.wav/direct ogg-stream url)
--- volume: 0-1 
--- x,y,z: position (omit for unspatialized)
--- max_dist  (omit for unspatialized)
function GUI:setAudioSource(name, url, volume, x, y, z, max_dist)
  SendNUIMessage({act="set_audio_source", name = name, url = url, x = x, y = y, z = z, volume = volume, max_dist = max_dist})
end

-- remove named audio source
function GUI:removeAudioSource(name)
  SendNUIMessage({act="remove_audio_source", name = name})
end

-- VoIP

function GUI:setPeerConfiguration(config)
  SendNUIMessage({act="set_peer_configuration", config=config})
end

-- request connection to another player for a specific channel
function GUI:connectVoice(channel, player)
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
function GUI:disconnectVoice(channel, player)
  SendNUIMessage({act="disconnect_voice", channel=channel, player=player})
end

-- register callbacks for a specific channel
--- on_offer(player): should return true to accept the connection
--- on_connect(player, is_origin): is_origin is true if it's the local peer (not an answer)
--- on_disconnect(player)
function GUI:registerVoiceCallbacks(channel, on_offer, on_connect, on_disconnect)
  if not self.channel_callbacks[channel] then
    self.channel_callbacks[channel] = {on_offer, on_connect, on_disconnect}
  else
    print("[vRP] VoIP channel callbacks for <"..channel.."> already registered.")
  end
end

-- check if there is an active connection
function GUI:isVoiceConnected(channel, player)
  local channel = self.voice_channels[channel]
  if channel then
    return channel[player] == 1
  end
end

-- check if there is a pending connection
function GUI:isVoiceConnecting(channel, player)
  local channel = self.voice_channels[channel]
  if channel then
    return channel[player] == 0
  end
end

-- enable/disable speaking
--- player: nil to affect all channel peers
--- active: true/false 
function GUI:setVoiceState(channel, player, active)
  SendNUIMessage({act="set_voice_state", channel=channel, player=player, active=active})
end

-- configure channel (can only be called once per channel)
--- config:
---- effects: map of name => true/options
----- spatialization => { max_dist: ..., rolloff: ..., dist_model: ... } (per peer effect)
----- biquad => { frequency: ..., Q: ..., type: ..., detune: ..., gain: ...} see WebAudioAPI BiquadFilter
------ freq = 1700, Q = 3, type = "bandpass" (idea for radio effect)
----- gain => { gain: ... }
function GUI:configureVoice(channel, config)
  SendNUIMessage({act="configure_voice", channel=channel, config=config})
end

-- receive voice peer signal
function GUI:signalVoicePeer(player, data)
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

function GUI:isSpeaking()
  return self.speaking
end


-- EVENT

GUI.event = {}

-- pause
function GUI.event:pauseChange(paused)
  SendNUIMessage({act="pause_change", paused=paused})
end

-- TUNNEL

GUI.tunnel = {}

-- MENU

function GUI.tunnel:openMenu(menudata)
  SendNUIMessage({act="open_menu", menudata = menudata})
end

function GUI.tunnel:closeMenu()
  SendNUIMessage({act="close_menu"})
end

-- PROMPT

function GUI.tunnel:prompt(title,default_text)
  SendNUIMessage({act="prompt",title=title,text=tostring(default_text)})
  SetNuiFocus(true)
end

-- REQUEST

function GUI.tunnel:request(id,text,time)
  SendNUIMessage({act="request",id=id,text=tostring(text),time = time})
  vRP.EXT.Base:playSound("HUD_MINI_GAME_SOUNDSET","5_SEC_WARNING")
end

GUI.tunnel.setPeerConfiguration = GUI.setPeerConfiguration
GUI.tunnel.signalVoicePeer = GUI.signalVoicePeer
GUI.tunnel.announce = GUI.announce
GUI.tunnel.setProgressBar = GUI.setProgressBar
GUI.tunnel.setProgressBarValue = GUI.setProgressBarValue
GUI.tunnel.setProgressBarText = GUI.setProgressBarText
GUI.tunnel.removeProgressBar = GUI.removeProgressBar
GUI.tunnel.setDiv = GUI.setDiv
GUI.tunnel.setDivCss = GUI.setDivCss
GUI.tunnel.setDivContent = GUI.setDivContent
GUI.tunnel.divExecuteJS = GUI.divExecuteJS
GUI.tunnel.removeDiv = GUI.removeDiv
GUI.tunnel.playAudioSource = GUI.playAudioSource
GUI.tunnel.setAudioSource = GUI.setAudioSource
GUI.tunnel.removeAudioSource = GUI.removeAudioSource

-- NUI

-- gui menu events
RegisterNUICallback("menu",function(data,cb)
  if data.act == "valid" then
    vRP.EXT.GUI.remote._triggerMenuOption(data.option+1,data.mod)
  end
end)

RegisterNUICallback("menu_state",function(data,cb)
  vRP.EXT.GUI.menu_state = data
end)

-- gui prompt event
RegisterNUICallback("prompt",function(data,cb)
  if data.act == "close" then
    SetNuiFocus(false)
    SetNuiFocus(false)
    vRP.EXT.GUI.remote._promptResult(data.result)
  end
end)

-- gui request event
RegisterNUICallback("request",function(data,cb)
  if data.act == "response" then
    vRP.EXT.GUI.remote._requestResult(data.id,data.ok)
  end
end)

-- init
RegisterNUICallback("init",function(data,cb) -- NUI initialized
  SendNUIMessage({act="cfg",cfg=vRP.cfg.gui}) -- send cfg
  TriggerEvent("vRP:NUIready")
end)

-- VoIP

RegisterNUICallback("audio",function(data,cb)
  if data.act == "voice_connected" then
    -- register channel/player
    local channel = vRP.EXT.GUI.voice_channels[data.channel]
    if not channel then
      channel = {}
      vRP.EXT.GUI.voice_channels[data.channel] = channel
    end
    channel[data.player] = 1 -- connected

    -- callback
    local cbs = vRP.EXT.GUI.channel_callbacks[data.channel]
    if cbs then
      local cb = cbs[2]
      if cb then cb(data.player, data.origin) end
    end
  elseif data.act == "voice_disconnected" then
    -- unregister channel/player
    local channel = vRP.EXT.GUI.voice_channels[data.channel]
    if channel then
      channel[data.player] = nil
    end

    -- callback
    local cbs = vRP.EXT.GUI.channel_callbacks[data.channel]
    if cbs then
      local cb = cbs[3]
      if cb then cb(data.player) end
    end
  elseif data.act == "voice_peer_signal" then
    vRP.EXT.GUI.remote._signalVoicePeer(data.player, data.data)
  end
end)

vRP:registerExtension(GUI)
