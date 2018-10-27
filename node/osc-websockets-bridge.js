var osc = require("osc"),
  express = require("express"),
  websocket = require("ws"),
  readline = require("readline"),
  argv = require('minimist')(process.argv.slice(2));
  Leap = require("leapjs");

const SONICPI = argv.s || false;
// const BROWSER = argv.b || false;
const USE_OSC_BUNDLES = !SONICPI;
const OSC_REMOTE_HOST = "0.0.0.0";
const OSC_REMOTE_PORT = argv._[0] || (SONICPI ? "4559" : "4567");
const WEBSOCKETS_PORT = 8081;
const WEBSOCKETS_TO_OSC_SEND_PORT = argv.osc || 4559;


// if(SONICPI) OSC_REMOTE_PORT= 4559;

const EVERY_N_FRAMES = argv.f || 1;
console.log('Sending every ' + EVERY_N_FRAMES + ' frames.');
console.log(argv);

var getIPAddresses = function () {
    var os = require("os"),
        interfaces = os.networkInterfaces(),
        ipAddresses = [];

    for (var deviceName in interfaces) {
        var addresses = interfaces[deviceName];
        for (var i = 0; i < addresses.length; i++) {
            var addressInfo = addresses[i];
            if (addressInfo.family === "IPv4" && !addressInfo.internal) {
                ipAddresses.push(addressInfo.address);
            }
        }
    }

    return ipAddresses;
};

// for catching keypresses
readline.emitKeypressEvents(process.stdin);
process.stdin.setRawMode(true);

process.stdin.on('keypress', (str, key) => {
  // if (key.ctrl && key.name === 'c') {
  //   process.exit();
  // } else {
  //
  // }

  // if(key.name === 'd') {
  //   argv.D = !argv.D;
  // } else {
  process.exit();
  // TODO: close all open ports neatly!
  // }
});


// // Sonic Pi forwarding port
// var piPort = new osc.UDPPort({
//     // OSC RECEIVE (listening) port:
//     localAddress: "0.0.0.0",
//     localPort:  9999, //argv._[1] || 57121, // || process.argv[2]

//     // OSC SEND (forwarding) port:
//     remoteAddress: "127.0.0.1",
//     remotePort: 4559 //7500 // process.argv[3] ||
// });
// piPort.open();


// Bind to a UDP socket to listen for incoming OSC events.
var udpPort = new osc.UDPPort({
    // OSC RECEIVE (listening) port:
    localAddress: "0.0.0.0",
    localPort:  argv._[1] || 57121, // || process.argv[2]

    // OSC SEND (forwarding) port:
    remoteAddress: "127.0.0.1",
  remotePort: WEBSOCKETS_TO_OSC_SEND_PORT // process.argv[3] ||
});

udpPort.on("ready", function () {
  var ipAddresses = getIPAddresses();
  console.log("Listening for OSC over UDP.");
  ipAddresses.forEach(function (address) {
      console.log(" Host:", address + ", Port:", udpPort.options.localPort);
  });
  console.log(`Listening for WebSockets connections at http://localhost:${WEBSOCKETS_PORT}/`);

  if(argv.leap){
    console.log(`Leap OSC sending to http://${OSC_REMOTE_HOST}:${OSC_REMOTE_PORT}/`);
    startLeap();
  }

});

udpPort.open();

// Create an Express-based Web Socket server to which OSC messages will be relayed.
var appResources = __dirname + "/web",
    app = express(),
    server = app.listen(WEBSOCKETS_PORT),
    wss = new websocket.Server({
        server: server
    });

app.use("/", express.static(appResources));

wss.on("connection", function (socket) {
    console.log("A Web Socket connection has been established.");
    var socketPort = new osc.WebSocketPort({
        socket: socket
    });

    var relay = new osc.Relay(udpPort, socketPort, {
        raw: true
    });

    // https://github.com/colinbdclark/osc.js/issues/18#issuecomment-107075771
    // socketPort.on("close", function () {
    // });
    socketPort.on("error", function () {
      // Need to do something, anything here to prevent error from killing this process
      // Seems to be more important to close relay here - don't seem to need the 'close' event handler??
      relay.close();
      console.log('Closed WebSocket relay due to socket disconnect!');
    });

});

var startLeap = function(){

  // var send = function(address, args){
  // };

  var frameCount = 0;

  var controller = Leap.loop(function(frame){

    if( (frameCount++ % EVERY_N_FRAMES) !== 0 ){ return; }

    if(frame.pointables.length){
      // console.log(frame.pointables[0].toString());
      // readline.clearScreenDown(process.stdout);
      // process.stdout.write(JSON.stringify(frame.pointables, null, 2));
      // readline.moveCursor(process.stdout, null, -19);
      // readline.cursorTo(process.stdout, 0);

      let bundle = [];

      var frontmostVal = 1;
      var frontmostArgs = [];
      var frontmostHandID = -1;

      frame.pointables.forEach(function (p, index){
        //Get a pointable and normalize the tip position
        var interactionBox = frame.interactionBox;
        var normPos = interactionBox.normalizePoint(p.stabilizedTipPosition, true);

        var fingerID = p.id % 10;
        var handID = p.hand().type === "right" ? 0 : 1;

        var args = [
          { type: 'f', value: normPos[0] },
          { type: 'f', value: normPos[1] },
          { type: 'f', value: normPos[2] }
        ];

        // fingertip positions
        bundle.push({ address: `/leap/${handID}/${fingerID}/pos`, args });

        // touchZone:
        // [0]: zone status -   'none'/'hovering'/'touching'
        // [1]: zone distance - [toward body +1 .. 0 .. -1 away from body]
        bundle.push({
          address: `/leap/${handID}/${fingerID}/touch`,
          args:[
            { type: 's', value: p.touchZone },
            { type: 'f', value: p.touchDistance }
          ]
        });

        if( normPos[2] < frontmostVal ){
          frontmostVal = normPos[2];
          frontmostArgs = args;
          frontmostHandID = handID;
        }
        // console.log(normPos);

      }); // each pointable

      if( frontmostHandID > -1 ){
        bundle.push({
          address: `/leap/${frontmostHandID}/pointer`,
          args: frontmostArgs
        });
      };

      if( USE_OSC_BUNDLES ){
        // Send all the finger messages togther in a single bundle
        // (set the time as empty because we don't want to schedule it in the future)
        udpPort.send({  timeTag: {}, packets: bundle }, OSC_REMOTE_HOST, OSC_REMOTE_PORT);
      } else {
        // Unforch Sonic Pi doesn't support OSC bundles yet
        // TODO: throttling???
        bundle.forEach( msg => udpPort.send(msg, OSC_REMOTE_HOST, OSC_REMOTE_PORT) );
      }

    } // pointables.length

    // if(frame.hands.length) { debugger }

    let handBundle = [];

    frame.hands.forEach( hand => {

      let handID = hand.type === "right" ? 0 : 1;

      // grab
      handBundle.push({
        address: `/leap/${handID}/grab`,
        args: [{ type: 'f', value: hand.grabStrength }]
      });

      // pinch
      handBundle.push({
        address: `/leap/${handID}/pinch`,
        args: [{ type: 'f', value: hand.pinchStrength }]
      });


      // if( hand.pinchStrength > 0.5 ){
      //   piPort.send({
      //     address: `/leap/${handID}/pinch`,
      //     args: [{ type: 'f', value: hand.pinchStrength }]
      //   });
      // }


      // sphereRadius
      handBundle.push({
        address: `/leap/${handID}/sphere`,
        args: [
        { type: 'f', value: hand.sphereRadius },
        { type: 'f', value: hand.sphereCenter[0] },
        { type: 'f', value: hand.sphereCenter[1] },
        { type: 'f', value: hand.sphereCenter[2] }
        ]
      });

      // palm center
      handBundle.push({
        address: `/leap/${handID}/palm`,
        args: [
          { type: 'f', value: hand.stabilizedPalmPosition[0] },
          { type: 'f', value: hand.stabilizedPalmPosition[1] },
          { type: 'f', value: hand.stabilizedPalmPosition[2] },
        ]
      });


      // TODO: roll the following into one message? POSX, POSY, POSZ, ROLL, PITCH, YAW
      //
      // palm center
      let roll = -hand.roll() / Math.PI;  // [left -0.5..0.5 right]
      // let roll = 180.0 * hand.roll() / Math.PI;  // [-90..90]
      handBundle.push({
        address: `/leap/${handID}/roll`,
        args: [{ type: 'f', value: roll }]
      });

      let pitch = hand.pitch() / Math.PI;  // [down -0.5..0.5 up]
      handBundle.push({
        address: `/leap/${handID}/pitch`,
        args: [{ type: 'f', value: pitch }]
      });

      let yaw = hand.yaw() / Math.PI;  // [left -0.5..0.5 right]
      handBundle.push({
        address: `/leap/${handID}/yaw`,
        args: [{ type: 'f', value: yaw }]
      });

      handBundle.push({
        address: `/leap/${handID}/time`,
        args: [{ type: 'f', value: hand.timeVisible }]
      });

    }); // each hand

    if( USE_OSC_BUNDLES && handBundle.length ){
      // debugger;
      udpPort.send({  timeTag: {}, packets: handBundle }, OSC_REMOTE_HOST, OSC_REMOTE_PORT);
    } else {
      handBundle.forEach( msg => udpPort.send(msg, OSC_REMOTE_HOST, OSC_REMOTE_PORT) );
    }

  }); // Leap.loop

}; // startLeap()
