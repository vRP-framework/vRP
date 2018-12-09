var cfg = {
  ports: {
    websocket: 4400,
    udp_range: [2000,4000] // define the range of UDP ports used by players (one per connection)
  },
  iceServers: [ // only needed if the server has issues to find its own IP
//    {urls: ["stun:stun1.l.google.com:19302", "stun:stun3.l.google.com:19302"]}
  ],
}

module.exports = cfg;
