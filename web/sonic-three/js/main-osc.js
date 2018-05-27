// run bridge with:
//   node js/osc-websockets-sonic-pi-bridge.js [listening-port] [sending-port]
// (Default listening port is 57121, sending port 4559 )
//
// Test with:
// oscsend osc.udp://localhost:57121 /test iifs 1 2 10.5 "yes"

var app = app  || {};

var oscPort = new osc.WebSocketPort({
    url: "ws://localhost:8081" // URL to your Web Socket server.
});
oscPort.open();

app.oscPort = oscPort;

// oscPort.on("connect/ready", function (msg) {  });

oscPort.on("message", function (msg) {
  // console.log(msg.address );

  // run handler for this message path
  if(msg.address in app.osc){
    app.osc[msg.address](msg.args);
  }

  // if(msg.address.indexOf('/note') === 0){
  //   console.log(oscData);
  //   const [note, noteNorm, sleep] = msg.args
  // }
});
