// run bridge with:
//   node js/osc-websockets-sonic-pi-bridge.js [listening-port] [sending-port]
// (Default listening port is 57121, sending port 4559 )
//
// Test with:
// oscsend osc.udp://localhost:57121 /test iifs 1 2 10.5 "yes"

let oscData = {};

var app = app  || {};

app.boom = 0;

const o = (path, ind=0) => {
  if(typeof oscData[path] === 'undefined') {
    return 0;
  }
  return oscData[path][ind];
};

var oscPort = new osc.WebSocketPort({
    url: "ws://localhost:8081" // URL to your Web Socket server.
});
oscPort.open();

// oscPort.on("connect/ready", function (msg) {  });

oscPort.on("message", function (msg) {
  // console.log(msg.address, msg.address.indexOf('/note') );

  oscData[msg.address] = msg.args;
  // console.log(oscData);

  if(msg.address.indexOf('/klub')){
    // app.randomCube(100, {x: app.controller.xSize, y: 4});
    app.randomCube(100, {
      x: app.controller.xSize,
      y: app.controller.xSize,
      z: app.controller.xSize
    });
    app.randCube = Math.floor(app.randRange(0, app.cubes.length));
  } else if(msg.address.indexOf('/boom')){
    console.log('booooooom');
    app.boom = 1.0;
  }

  // if(msg.address.indexOf('/note') === 0){
  //   console.log(oscData);
  //   const [note, noteNorm, sleep] = msg.args
  // }
});
