
function AudioEngine()
{
  this.c = new AudioContext();
  this.sources = {};
  this.listener = this.c.listener;
  this.listener.upX.value = 0;
  this.listener.upY.value = 0;
  this.listener.upZ.value = 1;

  this.last_check = new Date().getTime();
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
      var dx = data.x-source[2].positionX.value;
      var dy = data.y-source[2].positionY.value;
      var dz = data.z-source[2].positionZ.value;
      var dist = Math.sqrt(dx*dx+dy*dy+dz*dz);
      var active_dist = source[2].maxDistance*2;

      if(source[0].paused && dist <= active_dist)
        source[0].play();
      else if(!source[0].paused && dist > active_dist)
        source[0].pause();
    }
  }
}

// return [audio, node, panner]
AudioEngine.prototype.setupAudioSource = function(data)
{
  var audio = new Audio();
  audio.src = data.url;
  audio.volume = data.volume;

  var node = this.c.createMediaElementSource(audio);

  var panner = this.c.createPanner();
//  panner.panningModel = "HRTF";
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

  return [audio, node, panner];
}

AudioEngine.prototype.playAudioSource = function(data)
{
  var _this = this;

  var dx = this.listener.positionX.value-data.x;
  var dy = this.listener.positionY.value-data.y;
  var dz = this.listener.positionZ.value-data.z;
  var dist = Math.sqrt(dx*dx+dy*dy+dz*dz);
  var active_dist = source[2].maxDistance*2;

  if(dist <= active_dist){
    var source = this.setupAudioSource(data);

    // bind deleter
    source[0].onended = function(){
      source[2].disconnect(_this.c.destination);
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
  var dx = this.listener.positionX.value-source[2].positionX.value;
  var dy = this.listener.positionY.value-source[2].positionY.value;
  var dz = this.listener.positionZ.value-source[2].positionZ.value;
  var dist = Math.sqrt(dx*dx+dy*dy+dz*dz);
  var active_dist = source[2].maxDistance*2;

  if(dist <= active_dist)
    source[0].play();
}

AudioEngine.prototype.removeAudioSource = function(data)
{
  var source = this.sources[data.name];
  if(source){
    delete this.sources[data.name];
    if(!source[0].paused)
      source[0].pause();
    source[2].disconnect(this.c.destination);
  }
}
