var cfg = require("./config.js")

var ws = require("ws");
var wrtc = require("wrtc");

// create websocket server
var wss = new ws.Server({port: cfg.ports.websocket});
var players = {}; // map of id => {.ws, .peer, .channel, .channels}

// return true if player 1 and player 2 are connected by at least one channel
function checkConnected(p1, p2, channels)
{
  for(var i = 0; i < channels.length; i++){
    var channel_id = channels[i];
    if(p1.channels[channel_id] && p2.channels[channel_id] && p1.channels[channel_id][p2.id] && p2.channels[channel_id][p1.id])
      return true;
  }

  return false;
}

function errorHandler(e)
{
  console.log("error", e);
}

console.log("Server started.");
console.log("config = ", cfg);

wss.on("connection", function(ws, req){
  console.log("connection from "+req.connection.remoteAddress);

  // create peer
  var peer = new wrtc.RTCPeerConnection({iceServers: cfg.iceServers, portRange: {min: cfg.ports.webrtc_range[0], max: cfg.ports.webrtc_range[1]}});

  peer.onicecandidate = function(e){
    try{
      ws.send(JSON.stringify({act: "candidate", data: e.candidate}));
    }catch(e){ errorHandler(e); }
  }

  // create channel
  var dchannel = peer.createDataChannel("voip", {
    ordered: false,
    negotiated: true,
    maxRetransmits: 0,
    id: 0
  });

  dchannel.binaryType = "arraybuffer";

  dchannel.onopen = function(){
    console.log("UDP channel ready for "+req.connection.remoteAddress);
  }

  dchannel.onmessage = function(e){
    var player = ws.player;
    var buffer = e.data;

    if(player){ // identified
      // read packet
      // header
      var view = new DataView(buffer);
      var nchannels = view.getUint8(0);
      var channels = new Uint8Array(buffer, 1, nchannels);

      // build out packet
      var out_data = new Uint8Array(4+buffer.byteLength);
      var out_view = new DataView(out_data.buffer);
      out_view.setInt32(0, player.id); // write player id
      out_data.set(new Uint8Array(buffer), 4); // write packet data

      // send to channel connected players
      for(var id in players){
        var out_player = players[id];
        if(out_player.dchannel.readyState == "open" && checkConnected(player, out_player, channels)){
          try{
            out_player.dchannel.send(out_data.buffer);
          }catch(e){ errorHandler(e); }
        }
      }
    }
  }

  ws.on("message", function(data){
    data = JSON.parse(data);

    if(data.act == "answer")
      peer.setRemoteDescription(data.data).catch(errorHandler);
    else if(data.act == "candidate" && data.data != null)
      peer.addIceCandidate(data.data).catch(errorHandler);
    else if(data.act == "identification" && data.id != null){
      if(!players[data.id]){
        var player = {ws: ws, peer: peer, dchannel: dchannel, id: data.id, channels: {}};
        players[data.id] = player;
        ws.player = player;
        console.log("identification for "+req.connection.remoteAddress+" player id "+data.id);
      }
    }
    else if(data.act == "connect" && data.channel != null && data.player != null){
      var player = ws.player;
      if(player){
        var channel = player.channels[data.channel];
        if(!channel){ // create channel
          channel = {};
          player.channels[data.channel] = channel;
        }

        channel[data.player] = true;
      }
    }
    else if(data.act == "disconnect" && data.channel != null && data.player != null){
      var player = ws.player;
      if(player){
        var channel = player.channels[data.channel];
        if(channel){
          delete channel[data.player]; // remove player

          if(Object.keys(channel).length == 0) // empty, remove channel
            delete player.channels[data.channel];
        }
      }
    }
  });

  ws.on("close", function(){
    peer.close();
    var player = ws.player;
    if(player)
      delete players[player.id];
    console.log("disconnection of "+req.connection.remoteAddress);
  });

  peer.createOffer().then(function(offer){
    peer.setLocalDescription(offer).catch(errorHandler);
    try{
      ws.send(JSON.stringify({act: "offer", data: offer}));
    }catch(e){ errorHandler(e); }
  }).catch(errorHandler);
});
