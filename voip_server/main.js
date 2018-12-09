var cfg = require("./config.js")

var ws = require("ws");
var wrtc = require("wrtc");

// create websocket server
var wss = new ws.Server({port: cfg.ports.websocket});
var players = {}; // map of id => {.ws, .peer, .channel}

console.log("Server started.");
console.log("config = ", cfg);

wss.on("connection", function(ws){
  console.log("connection");

  // create peer
  var peer = new wrtc.RTCPeerConnection({iceServers: cfg.iceServers, portRange: {min: cfg.ports.udp_range[0], max: cfg.ports.udp_range[1]}});

  peer.onicecandidate = function(e){
    ws.send(JSON.stringify({act: "candidate", data: e.candidate}));
  }

  // create channel
  var channel = peer.createDataChannel("voip", {
    ordered: false,
    negotiated: true,
    maxRetransmits: 0,
    id: 0
  });

  channel.binaryType = "arraybuffer";

  channel.onopen = function(){
    console.log("channel ready");
  }

  channel.onmessage = function(e){
//    console.log("channel msg", e.data);
  }

  ws.on("message", function(data){
    data = JSON.parse(data);
    console.log("msg",data);
    if(data.act == "answer")
      peer.setRemoteDescription(data.data);
    else if(data.act == "candidate" && data.data != null)
      peer.addIceCandidate(data.data);
    else if(data.act == "identification" && data.id != null){
      if(!players[data.id]){
        players[data.id] = {ws: ws, peer: peer, channel: channel};
        ws.server_id = data.id;
        console.log("identitified ", data.id);
      }
    }
  });

  ws.on("close", function(){
    peer.close();
    if(ws.server_id != null && players[ws.server_id])
      delete players[ws.server_id];
  });

  peer.createOffer().then(function(offer){
    peer.setLocalDescription(offer);
    ws.send(JSON.stringify({act: "offer", data: offer}));
  });
});
