// https://github.com/processing/p5.js/wiki/p5.js-overview
// var ox, oy, oz, pinch;

let
  lx = 0,
  ly = 0,
  lz = 0,
  pinch = 0,
  roll = 0;

var capture;
var pg;
var h = 0;
var i = 0;
var j = 0;

let hands = [
  [{}, {}, {}, {}, {}],
  [{}, {}, {}, {}, {}],
];

const
  lh = hands[1],
  rh = hands[0];

var oscPort = new osc.WebSocketPort({
    url: "ws://localhost:8081" // URL to your Web Socket server.
});
oscPort.open();

oscPort.on("message", function (msg) {
  // console.log(msg);

  if(msg.address.indexOf('/leap/0/pinch') === 0){
    pinch = msg.args[0];
  } else if(msg.address.indexOf('/leap/0/roll') === 0){
    roll = msg.args[0];
  } else if(msg.address.indexOf('/leap') === 0){

    const [ , , hand, finger, norm, name] = msg.address.split('/');
    if(norm !== 'norm'){ return; }

    if(name === 'fpos'){
      hands[hand][finger] = { x: msg.args[0], y: msg.args[1], z: msg.args[2] };
      [lx, ly, lz] = msg.args;  // set globals
    }

    // else if (name ===){
    //

    }

});


function setup(){

  createCanvas(windowWidth, windowHeight);
  colorMode(HSB, 360, 100, 100);


  pg = createGraphics(100, 80);

  // oscy = new p5.TriOsc(); // set frequency and type
  // oscy.amp(.5);
  //
  // oscy.start();

  // capture = createCapture(VIDEO);
  // capture.size(320, 240);
  // capture.hide();
   // var myCanvas = createCanvas(600, 400);
   //  myCanvas.parent('myContainer');
  //  createCanvas(windowWidth, windowHeight, WEBGL);
  //  ortho(-width, width, height, -height/2, 0.1, 100);

}

function draw(){
  // console.log(frameRate());

  noStroke();
  //
  // if (mouseIsPressed) {
  //   //clear();
  //   fill(h++%360, 100, 100);
  //
  //   // image(capture, 0, 0, windowWidth, windowHeight);
  //   // filter('INVERT');
  //
  //   //  fill(0, 0, 0);
  //  } else {
  //   //  clear();
  //   //fill(h++%360, 100, 100);
  //    fill(+(oz*360), 100, 100);
  //  }

  fill(frameCount%360, 100, 100);

  //  y = windowHeight/2 + (Math.sin(i)) * ( windowHeight/2 - 40 );
  //  x = windowWidth/2 + (Math.cos(j)) * ( windowWidth/2 - 40 );
  //  pg.ellipse(x, y, 80, 80)
  //  pg.loadPixels();
  //  pg.pixels[ random(pg.width * pg.height) ] =
  //  pg.updatePixels();
  // pg.set(  50, 50, color(random(360), 100, 100) );
  // image(pg, 0, 0, windowWidth, windowHeight);
  // console.log(ox, oy, oz, pinch, ox*windowWidth, oy*windowHeight);
  // console.log(pinch);


  // Leap
  // ellipse(ox*windowWidth, (1.0 - oy)*windowHeight, size, size);

  rh.forEach(function(f){
    const size = (70 - (f.z * 70));  // set size from z-axis depth
     // const size = pinch * 100;
    ellipse( f.x*windowWidth, (1.0 - f.y)*windowHeight, size, size);
  });


  // change oscillator frequency based on mouseX
  // var freq = map(ly, 0, 1, 40, 1000);
  // freq = 600;
  // oscy.freq(freq);
  // var amp = map(pinch, 0, 1, 1, .01);
  // amp = 0.6;
  // oscy.amp(pinch);

  // console.log(pinch); //, lx, ly, lz);

  // ellipse(random(windowWidth), random(windowHeight), 80, 80);
  // ellipse(mouseX, mouseY, 80, 80);
}

let loopPause =  false;

function keyPressed() {
  if (key === ' ') {
    // console.log('k');
    loopPause = !loopPause;
    loopPause ? noLoop() : loop() ;
    console.log(loopPause ? "Paused draw()" : "Resuming..." );
  } else if( keyCode === ENTER ){
    clear();
  }
}
