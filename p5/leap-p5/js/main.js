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
//     app.controller.d2 = args.length > 1 ? args.join(', ') : args[0];
//   },
//
// };


function setup() {
  createCanvas(windowWidth, windowHeight);
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

function drawPoints( points ) {
  for( let i = 0; i < 5; i++ ){
    const path = `/leap/0/${ i }/pos`;
    if(path in points){
      const [x,y,z] = points[path];
      const size = (1.0-z) * 500;
      noStroke();
      fill(z*255, x*255, y*255); // fill(random(255), random(255), 255);
      ellipse(
        x*windowWidth,
        (1.0-y)*windowHeight,
        size,size
      );
    }
  }
}

function draw() {

  if( !keyIsDown(CONTROL) ){
    // background(0);
  }

  if( keyIsDown(SHIFT) ){
    console.log(oscData);
  }

  if( oscData['/leap/0/grab'] < 0.5 ){
    background(0);
  }

  drawPoints(oscData);
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
    case 32: break;  // space
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
