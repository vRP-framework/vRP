var cfg = {
  ports: {
    websocket: 40120, // TCP
    webrtc_range: [10000,11000] // UDP, define the range of ports which can be used by players (one per connection)
  },
  iceServers: [ // only needed if the server has issues to find its own IP
//    {urls: ["stun:stun1.l.google.com:19302", "stun:stun3.l.google.com:19302"]}
  ],
}

module.exports = cfg;
