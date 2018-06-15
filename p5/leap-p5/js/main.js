// while true; do node osc-websockets-bridge.js 57121 ; done

var app = app || {};

// app.osc = {
//   // DEBUG: true,
//   // DATA: true,
//   data: {},
//   setData: function(path, args, force=false){
//     if(this.DEBUG || force){
//       console.log(path, args);
//       this.data && console.log(this.data);
//     }
//     if(this.DATA){
//       this.data[path] = args;
//     }
//   },
//   // '/boom': function( args ){
//   //   this.setData('/boom', args);
//   // },
//   '/log': function( args ){
//     this.setData( '/log', args );
//     app.controls.d2 = args.length > 1 ? args.join(', ') : args[0];
//   },
//
// };

app.controls = {
  scale: 1.0,
  debug: 0,
  pitch: 0,
  roll: 0,
  yaw: 0,
  grab: 0,
  pinch: 0,
  lightColour: { h:1, s:1, v:1 },
  grabThreshold: 0.5,
  particleVelScale: 0.1,
  particleLifeTick: 0.05,
  vx: 0, vy: 0, vz: 0,
};

app.leap = {
  left:  [{x:0,y:0,z:0}, {x:0,y:0,z:0}, {x:0,y:0,z:0}, {x:0,y:0,z:0}, {x:0,y:0,z:0}],
  right: [{x:0,y:0,z:0}, {x:0,y:0,z:0}, {x:0,y:0,z:0}, {x:0,y:0,z:0}, {x:0,y:0,z:0}]
};

// app.particles = {
//   0: [ [], [], []. [], [] ],  //left
//   1: [ [], [], []. [], [] ],  //right
// };

app.particles = [];


app.gui = new dat.GUI();
// app.gui.addColor( app.controls, 'lightColour').onChange( val => {
//   app.ambient.color.setHSL(val.h, val.s, val.v);
// });
app.gui.add( app.controls, 'scale', 0, 1 );
app.gui.add( app.controls, 'grabThreshold', 0, 1 );
app.gui.add( app.controls, 'debug', 0, 1 ).listen()
app.gui.add( app.controls, 'pitch', -0.5, 0.5 ).listen()
app.gui.add( app.controls, 'roll', -0.5, 0.5 ).listen()
app.gui.add( app.controls, 'yaw', -0.5, 0.5 ).listen()
app.gui.add( app.controls, 'grab', 0, 1 ).listen()
app.gui.add( app.controls, 'pinch', 0, 1 ).listen()
app.gui.add( app.controls, 'vx', -0.5, 0.5 ).listen()
app.gui.add( app.controls, 'vy', -0.5, 0.5 ).listen()
app.gui.add( app.controls, 'vz', -0.5, 0.5 ).listen()
app.gui.add( app.controls, 'particleVelScale', -0.5, 0.5 );
app.gui.add( app.controls, 'particleLifeTick', 0, 0.1);

// app.gui.add( app.controls, 'rotationSpeed', 0, 1 );
// app.gui.add( app.controls, 'bouncingSpeed', 0, 2 );
// app.gui.add( app.controls, 'cubeScale', 0, 2 );
// app.gui.add( app.controls, 'xSize', 10, 500 );
// app.gui.add( app.controls, 'boomDec', 0, 0.2 );
// app.gui.add( app.controls, 'xRot', 0, 0.2 );
// app.gui.add( app.controls, 'cameraRot', 0, 0.1 );
// app.gui.add( app.controls, 'debug').listen();
// app.gui.add( app.controls, 'd2').listen();
// app.gui.add( app.controls, 'bpm', 30, 160).onChange( val => {
//   app.oscPort.send({
//       address: "/controls",
//       args: [
//         {type: "s", value: 'bpm'},
//         {type: "i", value: val},
//       ]
//     });
// });

var s;

// function preload() {
//   s = loadShader("line.vert","line.frag");
// }

function setup() {
  createCanvas(windowWidth, windowHeight); //, WEBGL);
  colorMode(HSB, 255);
  // pixelDensity(1);  // disable Retina density, for per-pixel stuff
  // rectMode(CORNERS);
  // background(0);
  // noStroke();
  // noFill();
  // stroke(255);
  // ellipse(windowWidth/2, windowHeight/2, 100, 100);
  // noLoop(); // no draw loop, use redraw() to call draw() once

}

function drawPoints( points, hand ) {
  let fingers = app.leap[ hand == 0 ? 'left' : 'right' ];
  const grab  = points[`/leap/${ hand }/grab`];
  const roll  = points[`/leap/${ hand }/roll`];
  const pitch = points[`/leap/${ hand }/pitch`];
  const pinch = points[`/leap/${ hand }/pinch`];


  for( let i = 0; i < 5; i++ ){
    const path = `/leap/${ hand }/${ i }/pos`;
    if(path in points){
      const [x,y,z] = points[path];
      const vx = x - fingers[i].x, vy = y - fingers[i].y, vz = z - fingers[i].z;
      fingers[i].x = x, fingers[i].y = y, fingers[i].z = z; //  { x, y, z }; //,   vx, vy, vz };


      let touch = 1.0;
      if( points[`/leap/${ hand }/${ i }/touch`] ){
        touch = points[`/leap/${ hand }/${ i }/touch`][1];
        touch = (touch/2.0 + 0.5);
      }

      if( i == 1 ){
        app.controls.debug = touch;
        app.controls.vx = vx; app.controls.vy = vy;  app.controls.vz = vz;
      }

      // const size = (1.0-z) * 500;
      // const size = grab * 200;
      // const size = roll * 300  +  Math.max( Math.abs(vx), Math.abs(vy) )  * 300;
      const size = Math.max( Math.abs(vx), Math.abs(vy) ) * 1000;

      fill(
        (z)*255,
        255,
        (1-pinch)*255 // fill(random(255), random(255), 255);
      );
      ellipse(
        x*windowWidth,
        (1.0-y)*windowHeight,
        size,size
      );

      app.particles.push({
        x, y, z, vx, vy, vz, hand, life: 1.0, index: i,
        pinch, grab, roll, size
      });

    }
  }
}

function updateParticles(){
  let buffer = [];
  for( let i = 0; i < app.particles.length; i++ ){
    const p = app.particles[i];
    p.x += p.vx * app.controls.particleVelScale;
    p.y += p.vy * app.controls.particleVelScale;
    p.z += p.vz * app.controls.particleVelScale;

    p.vy += 0.01 * mx();

    p.life -= app.controls.particleLifeTick;
    if(p.life >= 0){
     buffer.push(p);
    }

    fill(
      (p.z)*255,
      255,
      (1-p.pinch)*255 // fill(random(255), random(255), 255);
    );
    ellipse(
      p.x*windowWidth,
      (1.0-p.y)*windowHeight,
      p.size,p.size
    );
  }
  app.particles = buffer;
}

function draw() {

  if( !keyIsDown(CONTROL) ){
    // background(0);
  }

  if( keyIsDown(SHIFT) ){
    console.log(oscData);
  }


  app.controls.pitch = oscData['/leap/0/pitch'];
  app.controls.roll  = oscData['/leap/0/roll'];
  app.controls.yaw   = oscData['/leap/0/yaw'];
  app.controls.grab  = oscData['/leap/0/grab'];
  app.controls.pinch = oscData['/leap/0/pinch'];

  if( oscData['/leap/0/grab'] < app.controls.grabThreshold ){
    background(0);
  }

  noStroke();
  drawPoints(oscData, 0); // right hand
  drawPoints(oscData, 1); // left hand

  updateParticles();

  // shader(s);
}

// normalised mouse positions, with optional multiplier
function mx(max=1.0){
  return mouseX / windowWidth * max;
}

function my(max=1.0){
  return mouseY / windowWidth * max;
}


function keyPressed(e){
  switch(e.keyCode){
    case 13: break;  // enter
    case 32:
      app.particles = [];
      background(0);
      break;  // space
  }
}

function mouseMoved() {
  // ellipse(mouseX, mouseY, 5, 5);
  return false; // prevent default
}

function mousePressed() {
  // test: mouseButton
  return false; // prevent default
}

function mouseDragged() {
  return false; // prevent default
}

// function touchMoved() {
//   return false; // prevent default
// }
