
var is_playing = function(media)
{
  return media.currentTime > 0 && !media.paused && !media.ended && media.readyState > 2;
}

function AudioEngine()
{
  this.c = new AudioContext();
  this.sources = {};
  this.listener = this.c.listener;
  this.listener.upX.value = 0;
  this.listener.upY.value = 0;
  this.listener.upZ.value = 1;

  this.last_check = new Date().getTime();

  //VoIP
  this.voice_channels = {}; 
}

AudioEngine.prototype.setListenerData = function(data)
{
  var l = this.listener;
  l.positionX.value = data.x;
  l.positionY.value = data.y;
  l.positionZ.value = data.z;
  l.forwardX.value = data.fx;
  l.forwardY.value = data.fy;
  l.forwardZ.value = data.fz;

  var time = new Date().getTime();
  if(time-this.last_check >= 2000){ // every 2s
    this.last_check = time;

    // pause too far away sources and unpause nearest sources paused
    for(var name in this.sources){
      var source = this.sources[name];

      if(source[3]){ //spatialized
        var dx = data.x-source[2].positionX.value;
        var dy = data.y-source[2].positionY.value;
        var dz = data.z-source[2].positionZ.value;
        var dist = Math.sqrt(dx*dx+dy*dy+dz*dz);
        var active_dist = source[2].maxDistance*2;

        if(!is_playing(source[0]) && dist <= active_dist)
          source[0].play();
        else if(is_playing(source[0]) && dist > active_dist)
          source[0].pause();
      }
    }
  }
}

// return [audio, node, panner]
AudioEngine.prototype.setupAudioSource = function(data)
{
  var audio = new Audio();
  audio.src = data.url;
  audio.volume = data.volume;

  var spatialized = (data.x != null && data.y != null && data.z != null && data.max_dist != null);
  var node = null;
  var panner = null;

  if(spatialized){
    node = this.c.createMediaElementSource(audio);

    panner = this.c.createPanner();
//    panner.panningModel = "HRTF";
    panner.distanceModel = "inverse";
    panner.refDistance = 1;
    panner.maxDistance = data.max_dist;
    panner.rolloffFactor = 1;
    panner.coneInnerAngle = 360;
    panner.coneOuterAngle = 0;
    panner.coneOuterGain = 0;
    panner.positionX.value = data.x;
    panner.positionY.value = data.y;
    panner.positionZ.value = data.z;

    node.connect(panner);
    panner.connect(this.c.destination);
  }

  return [audio, node, panner, spatialized];
}

AudioEngine.prototype.playAudioSource = function(data)
{
  var _this = this;

  var spatialized = (data.x != null && data.y != null && data.z != null && data.max_dist != null);
  var dist = 10;
  var active_dist = 0;

  if(spatialized){
    var dx = this.listener.positionX.value-data.x;
    var dy = this.listener.positionY.value-data.y;
    var dz = this.listener.positionZ.value-data.z;
    dist = Math.sqrt(dx*dx+dy*dy+dz*dz);
    active_dist = data.max_dist*2;
  }

  if(!spatialized || dist <= active_dist){
    var source = this.setupAudioSource(data);

    // bind deleter
    if(spatialized){
      source[0].onended = function(){
        source[2].disconnect(_this.c.destination);
      }
    }

    // play
    source[0].play();
  }
}

AudioEngine.prototype.setAudioSource = function(data)
{
  this.removeAudioSource(data);

  var source = this.setupAudioSource(data);
  source[0].loop = true;
  this.sources[data.name] = source;

  // play
  var dist = 10;
  var active_dist = 0;
  if(source[3]){ // spatialized
    var dx = this.listener.positionX.value-source[2].positionX.value;
    var dy = this.listener.positionY.value-source[2].positionY.value;
    var dz = this.listener.positionZ.value-source[2].positionZ.value;
    dist = Math.sqrt(dx*dx+dy*dy+dz*dz);
    active_dist = source[2].maxDistance*2;
  }

  if(!source[3] || dist <= active_dist)
    source[0].play();
}

AudioEngine.prototype.removeAudioSource = function(data)
{
  var source = this.sources[data.name];
  if(source){
    delete this.sources[data.name];
    if(is_playing(source[0]))
      source[0].pause();
    if(source[3]) //spatialized
      source[2].disconnect(this.c.destination);
  }
}

//VoIP

AudioEngine.prototype.setupPeerCallbacks = function(peer)
{
  //setup data channel
  peer.data_channel.onopen = function(){
    $.post("http://vrp/audio",JSON.stringify({act: "voice_connected", player: peer.player, channel: data.channel})); 
  }

  peer.data_channel.onclose = function(){
    $.post("http://vrp/audio",JSON.stringify({act: "voice_disconnected", player: peer.player, channel: data.channel})); 
  }

  peer.data_channel.onmessage = function(e){
  }

  peer.conn.onicecandidate = function(e){
    $.post("http://vrp/audio",JSON.stringify({act: "voice_ice_candidate", player: peer.player, channel: data.channel, candidate: e.candidate})); 
  }
}

AudioEngine.prototype.connectVoice = function(data)
{
  //close previous peer
  this.disconnectVoice(data);

  //setup new peer
  var peer = {
    conn: new RTCPeerConnection({iceServers: [{urls:["stun.l.google.com:19302"]}]}),
    channel: data.channel,
    player: data.player
  }
  channel[data.player] = peer;

  //create data channel
  peer.data_channel = peer.conn.createDataChannel(data.channel);
  this.setupPeerCallbacks(peer);

  //SDP
  peer.createOffer().then(function(sdp){
    $.post("http://vrp/audio",JSON.stringify({act: "voice_sdp_offer", player: data.player, channel: data.channel, sdp: sdp})); 
    peer.conn.setLocalDescription(sdp);
  });
}

AudioEngine.prototype.disconnectVoice = function(data)
{
  var channel = this.voice_channels[data.channel];
  if(channel){
    //close peer
    var peer = channel[data.player];
    if(!peer || peer.conn.connectionState == "closed")
      peer.conn.close();

    delete channel[data.player];
  }
}

