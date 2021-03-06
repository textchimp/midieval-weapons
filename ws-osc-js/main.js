var app = app || {};

app.rows = 40;
app.cols = 40;


app.config = {

  numParticles: 2000,
  particleDistribution: 300,
  particleSize: 8,
  velocityScale: 1.0,
  gravityScale: 0.05,



  splinePoints: 100,
  splineTour: false,
  cameraPosIndex: 0,

  initialCameraPosition: [496, -53, -540],
  numBoxes: 100, //600
  boxDistribution: 100,
  spotlightMovement: 60,
  boxScale: 1,
  boxSizeRange: 20,
  boxRotationScale: 0.0,
  xScale: 1,
  yScale: 6,
  zScale: 1,
  boxOpacity: 0.2,
  ambientColour: '#FFFFFF',
  spotColour: '#000000',  //'#FFFFFF',
  directionalColour: '#FF0000',
  colourCycle: 300,
  xMoveScale: 1,
  yMoveScale: 1.01,
  zMoveScale: 1,
  moveCycle: 0.0,
  lightMoveScale: 1.0,
  triggerFadeScale: 0.1,
  tour: false,
  isPaused: false,
  showStats: false,

  debug: ' hi ',

  store:  function(){
    console.log('config:');
    console.log(JSON.stringify(app.config));
    localStorage.setItem('codevember4Config', app.config);
  }
};

app.step = 0;
app.cameraAngle = 0;

app.init = function () {

  document.addEventListener('keydown', function(e) {
    if( e.keyCode === 32){
      // spacebar to pause
      app.config.isPaused = !app.config.isPaused;
      !app.config.isPaused && app.animate(); // restart animation
    } else if( e.key === 'f' ){
      // 'f' to show/hide stats
      app.config.showStats = !app.config.showStats;
      app.stats.showPanel( app.config.showStats ? 0 : false );
    } else if( e.key === 't' ){
      // 't' to toggle tour mode (camera movement)
      app.config.tour = !app.config.tour;
    }
  });

  app.scene = new THREE.Scene();
  app.width = window.innerWidth;
  app.height = window.innerHeight;

  app.camera = new THREE.PerspectiveCamera(60, app.width/app.height, 0.1, 5000 );
  app.camera.position.set(...app.config.initialCameraPosition);
  app.camera.lookAt( app.scene.position );

  app.renderer = new THREE.WebGLRenderer();
  app.renderer.setSize( app.width, app.height );
  app.renderer.setClearColor( 0x000000 ); //background

  // app.scene.add( new THREE.AxisHelper(40) );

  app.ambientLight = new THREE.AmbientLight(); //soft white ambientLight from everywhere
  app.ambientLight.color.set( app.config.ambientColour );
  app.scene.add( app.ambientLight );





  // DirectionalLight = "sun's rays, infinite distance, parallel"
  // PointLight = lightbulb, light from a point equally in all directions
  // SpotLight = light facing in specific direction

  // app.spotlight = new THREE.HemisphereLight( 0xFFFFFF );

  app.spotlight = new THREE.PointLight( app.config.spotColour );
  // PointLight( color, intensity=1, distance=0, decay=1 )

  // app.spotlight = new THREE.DirectionalLight( 0xFF0022 , 1 );
  app.spotlight.position.set( -10, 20, 10 );
  app.scene.add( app.spotlight );

  // app.scene.add( new THREE.PointLightHelper( app.spotlight ) );

  // app.lightbox = new THREE.Mesh(
  //   new THREE.BoxGeometry( 30, 30, 30 ),
  //   new THREE.MeshStandardMaterial({ color: '#ffffff' })
  // );
  // app.lightbox.position = app.spotlight.position;
  // app.scene.add( app.lightbox );



  app.spline = app.createSpline();

  // app.line = app.createLineFromSpline( app.spline );
  // app.scene.add( app.line );



  app.particleSystem = app.createParticleSystem();
  app.scene.add( app.particleSystem );


app.directionalLight = new THREE.PointLight( 0xFFFFFF , 10, 200, 0.8 );
app.directionalLight.position.set( -10, 10, 20 );
app.scene.add( app.directionalLight );

// app.addLights( app.config.numLights );
//
// app.directionalLightHelper = new THREE.PointLightHelper( app.directionalLight )
// app.scene.add( app.directionalLightHelper );


  app.controls = new THREE.OrbitControls( app.camera, app.renderer.domElement );

  app.initControlPanel();

  // app.renderer.domElement.addEventListener('mousemove', function () {
  //   app.lastMouseTime = Date.now();
  // });

  app.boxFleet = app.initBoxes(
    parseInt(app.config.numBoxes),
    app.config.boxDistribution,
    app.config.boxSizeRange
   );

  //  app.directionalLight.target = app.boxFleet[0];

  app.stats = app.addStats();
  app.stats.showPanel( false );

  document.getElementById("output").appendChild( app.renderer.domElement );
  app.animate();
}; // init


app.initControlPanel= function(){
  app.gui = new dat.GUI();
  app.gui.add( app.config, 'numBoxes', 1, 1000 ).name('Box Count').onChange( app.resetBoxes );
  app.gui.add( app.config, 'boxDistribution', 1, 1000 ).name('Box Spread').onChange( app.resetBoxes );
  app.gui.add( app.config, 'spotlightMovement', 1, 100 ).name('Light Movement');
  app.gui.add( app.config, 'colourCycle', 1, 1000 );
  app.gui.add( app.config, 'boxOpacity', 0.0, 1.0 ).name('Box Opacity').onChange(function(){
    app.boxFleet.forEach( box => {
      box.material.transparent = app.config.boxOpacity < 1.0 ? true : false;
      box.material.opacity = app.config.boxOpacity;
    });
  });
  app.gui.add( app.config, 'boxRotationScale', 0, 10  ).name('Box Rotation');
  app.gui.add( app.config, 'boxScale', 1, 20 ).name('Box Scale');
  app.gui.add( app.config, 'xScale', 1, 20 ).name('Box X Scale');
  app.gui.add( app.config, 'yScale', 1, 20 ).name('Box Y Scale');
  app.gui.add( app.config, 'zScale', 1, 20 ).name('Box Z Scale');

  app.gui.addColor( app.config, 'ambientColour').onChange(function(){
    app.ambientLight.color.set( app.config.ambientColour );
  });
  app.gui.addColor( app.config, 'spotColour').onChange(function(){
    app.spotlight.color.set( app.config.spotColour );
  });
  app.gui.addColor( app.config, 'directionalColour').onChange(function(){
    app.directionalLight.color.set( app.config.directionalColour );
  });

  app.gui.add( app.config, 'moveCycle', 0.0, 0.1);
  app.gui.add( app.config, 'xMoveScale', 1, 200 ).name('X Move Scale');
  app.gui.add( app.config, 'yMoveScale', 1, 200 ).name('Y Move Scale');
  app.gui.add( app.config, 'zMoveScale', 1, 200 ).name('Z Move Scale');

  app.gui.add( app.config, 'lightMoveScale', 0, 2 ).name('Light Move Scale');
  app.gui.add( app.config, 'triggerFadeScale', 0, 0.1 ).name('Trigger Fade');

  app.gui.add( app.config, 'tour' ).name('Tour Mode').listen();

  app.gui.add( app.config, 'debug' ).listen();

  app.gui.add( app.config, 'store');
};


app.animateSplineTour = function(){

  const steps = 30000;

  app.config.cameraPosIndex++;
  if( app.config.cameraPosIndex > app.config.splinePoints ){
    app.config.cameraPosIndex = 0;
  }

  // Get a point a short distance ahead along the spline, and move camera to that point
  var newCameraPos = app.spline.getPoint( app.config.cameraPosIndex / steps );
  app.camera.position.set(newCameraPos.x, newCameraPos.y, newCameraPos.z  );

  // Get tanget to that point, and set camera rotatation and focus so it's always looking along the track
  var newCameraRot = app.spline.getTangent( app.config.cameraPosIndex / steps);
  app.camera.rotation.set(newCameraRot.x, newCameraRot.y, newCameraRot.z);
  const newCameraLookAt = app.spline.getPoint( (app.config.cameraPosIndex + 1) / steps ); // look 1 step ahead of current position

  // app.camera.lookAt( newCameraLookAt );
  app.camera.lookAt( app.scene.position );

};

app.animate = function () {

  if(app.config.isPaused){
    return;
  }

  app.stats.begin();

  if( app.config.splineTour ){
    app.animateSplineTour();
  }

  if( app.config.tour ){
    var radius = 50;
    app.camera.position.x = radius * Math.cos( app.cameraAngle );
    app.camera.position.z = radius * Math.sin( app.cameraAngle );
    // app.camera.position.y = radius * Math.cos( app.cameraAngle );
    app.camera.lookAt( app.scene.position );
    app.cameraAngle += 0.004;
  }

  app.directionalLight.position.set(
    300 * Math.sin( app.step ) * app.config.lightMoveScale,
    200 * Math.sin( app.step ) * app.config.lightMoveScale,
    200 * Math.cos( app.step ) * app.config.lightMoveScale
    // -10,
    // 100 * Math.sin( app.step ),
    // 100 * Math.cos( app.step )
  );
  app.directionalLight.intensity =  (1 -  Math.cos(app.step * 2) ) * 20;

  // app.directionalLight.lookAt( app.scene.position );
  // app.directionalLightHelper.update();



  // app.lightbox.position.set(
  //   app.spotlight.position.x, app.spotlight.position.y, app.spotlight.position.z
  // );


  app.animateParticles();

  app.step += 1/app.config.spotlightMovement;

  app.animateBoxes( app.boxFleet );

  app.renderer.render( app.scene, app.camera );

  app.stats.end();

  requestAnimationFrame( app.animate );
};

app.addStats = function () {
  var stats = new Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.getElementById("stats").appendChild( stats.domElement );
  return stats;
};

app.onResize = function () {
  app.width = window.innerWidth;
  app.height = window.innerHeight;
  app.camera.aspect = app.width / app.height;
  app.camera.updateProjectionMatrix();
  app.renderer.setSize(app.width, app.height);
};
window.addEventListener("resize", app.onResize, false);

app.resetBoxes = function(){
  app.boxFleet.forEach( box => app.scene.remove(box) );
  app.boxFleet = app.initBoxes(
    parseInt(app.config.numBoxes),
    app.config.boxDistribution,
    app.config.boxSizeRange
 );
};

app.initBoxes = function( count, dist, sizeRange ){
  var fleet = app.createBoxes( count, dist, sizeRange );
  fleet.forEach( box => app.scene.add(box) );
  return fleet;
};

app.createBoxes = function( boxCount, placementRange, sizeRange){

  var boxes = new Array( boxCount );

  for( var i = 0; i < boxes.length; i++) {

    var boxSize =  THREE.Math.randFloat(2, sizeRange);
    // var boxGeometry = new THREE.BoxGeometry(  boxSize, boxSize, boxSize );
     var boxGeometry = new THREE.CylinderGeometry( 6, 6, 40, 20);
    var boxMaterial =  new THREE.MeshStandardMaterial({   // THREE.MeshLambertMaterial
      wireframe: false,
      transparent: app.config.boxOpacity < 1.0 ? true : false,
      opacity: app.config.boxOpacity,
      // map: THREE.ImageUtils.loadTexture("/img/el.png")
    });

    boxes[i] = new THREE.Mesh( boxGeometry, boxMaterial );
    boxes[i].position.set(
      THREE.Math.randFloatSpread( placementRange ),
      0, // THREE.Math.randFloatSpread( placementRange ),
      THREE.Math.randFloatSpread( placementRange )
    );

    boxes[i].originalPosition = {
      x: boxes[i].position.x,
      y: boxes[i].position.y,
      z: boxes[i].position.z,
    };
    // Object.assign( boxes[i].position );

    // boxes[i].material.color.setRGB( Math.random(), Math.random(), Math.random() );
    boxes[i].material.color.setHSL( Math.random(),  1.0, 0.5);
    boxes[i].rotate_step = THREE.Math.randFloat( -0.01, 0.01 );

    boxes[i].xMoveInc = THREE.Math.randInt(1, 10);
    boxes[i].xMoveStep = THREE.Math.randFloat(0, 1);
    boxes[i].yMoveInc = THREE.Math.randInt(1, 10);
    boxes[i].yMoveStep = THREE.Math.randFloat(0, 1);
    boxes[i].zMoveInc = THREE.Math.randInt(1, 10);
    boxes[i].zMoveStep = THREE.Math.randFloat(0, 1);

    // boxes[i].wave_step = THREE.Math.randFloat( 0.0, 1.0 );
    // boxes[i].ystep = 0;
    boxes[i].castShadow = false;

    boxes[i].visible = false;

    boxes[i].material.opacity = 0;

  }
  return boxes;
};

app.animateBoxes = function( fleet ){
  const conf = app.config;

  // const time = Date.now() * 0.0005;
  // var clock = new THREE.Clock(); // in init
  // var delta = clock.getDelta(); // in animate
  // if( object ) object.rotation.y -= 0.5 * delta;

  for( let i = 0; i < fleet.length; i++ ){
    const box = fleet[i];

    if( conf.colourCycle ){
      var hsl  = box.material.color.getHSL();
      box.material.color.setHSL( (hsl.h + 1/conf.colourCycle)%1.0, 1.0, 0.5);
    }

    // box.rotation.y += box.rotate_step;
    // if( i%2 ){
      // box.rotation.x += box.rotate_step * conf.boxRotationScale;
    // } else {
      box.rotation.y += box.rotate_step * conf.boxRotationScale;
    // }

    if( conf.xMoveScale > 1 ){
      box.xMoveInc += box.xMoveStep * conf.moveCycle;
      box.position.x = box.originalPosition.x + conf.xMoveScale * Math.sin(box.xMoveInc);
    }
    if( conf.yMoveScale > 1 ){
      box.yMoveInc += box.yMoveStep * conf.moveCycle;
      box.position.y = box.originalPosition.y + conf.yMoveScale * Math.sin( box.yMoveInc );
      // i === 0 && (conf.debug = conf.moveCycle);
    }
    if( conf.zMoveScale > 1 ){
      box.zMoveInc += box.zMoveStep * conf.moveCycle;
      box.position.z = box.originalPosition.z + conf.zMoveScale * Math.sin(box.zMoveInc);
    }


    box.scale.set(
      conf.xScale * conf.boxScale,
      conf.yScale * conf.boxScale * (box.scaleY || 1),
      conf.zScale * conf.boxScale
    );

    // OSC trigger fade effect
    // if( box.material.opacity > 0 ) {
    //   box.material.opacity -= box.fade;
    //   // box.fade -= 0.0001;
    //   box.scale.x
    // } else {
    //   box.scale.set(0.00001, 0.00001, 0.00001);
    // }

    if( box.fade > 0 ){
      box.fade--;
      box.triggerYScale -= box.fadeStep;

      // box.material.opacity -= box.fadeStep;
      // app.config.debug = box.triggerZScale;
      // console.log(box.triggerZScale);
    } else {
      box.visible = false;
    }
    box.scale.y *= box.triggerYScale;

    // weird wave layers
    // box.position.y =  Math.cos( (app.step + box.rotate_step*200) ) * box.rotate_step * 10000;
    // variable
    // box.position.x = 10 + Math.sin( box.wave_step+=0.05 ) * box.rotate_step * 10000;  //Math.sqrt(box.position.y);

  } // for each box
};


app.createSpline = function(){

  const range = 200;
  var randomPoints = [];
  for (var i = 0; i < app.config.splinePoints; i++) {

    randomPoints.push(new THREE.Vector3(
      // randRange(-100, 100)

      THREE.Math.randInt(-range, range),  // x
      THREE.Math.randInt(-range, range),  // y
      THREE.Math.randInt(-range, range),  // z
    ));

  }

  // return new THREE.SplineCurve3( randomPoints );
  return new THREE.CatmullRomCurve3( randomPoints );
};


app.createLineFromSpline = function( spline ){

  var lineMaterial = new THREE.LineBasicMaterial({
    color: 0xFF00F0
  });

  var lineGeometry = new THREE.Geometry();
  var splinePoints = spline.getPoints( app.config.splinePoints );

  for (var i = 0; i < splinePoints.length; i++) {
    lineGeometry.vertices.push( splinePoints[i] );
  }

  var line = new THREE.Line( lineGeometry, lineMaterial );

  return line;
};


app.oscHandler = function(address, args){

  // console.log('handler');

  // let [{count: value}, {dur: value}] = args;

  const count = args[0].value;
  const dur   = args[1].value;
  const note  = THREE.Math.clamp(args[2].value, 29, 100);

  const noteNorm = (note - 29) / 70.0;
  // console.log({note, noteNorm});

    // % 12;  // don't mod to handle multiple octaves as a range?

  // const fade = dur/2;
  let randRod = THREE.Math.randInt(0, app.boxFleet.length);

  // if(!(app.boxFleet.material.opacity > 0)){
  //   randRod = 0;
  // }

  // console.log(count , dur, randRod, app.boxFleet[randRod] );
  // console.log('%c app.oscHandler', 'color: green', address, args);
  app.boxFleet[randRod].material.opacity = 1.0;
  app.boxFleet[randRod].visible = true;
  app.boxFleet[randRod].note = note;
  app.boxFleet[randRod].scaleY = 1.5 - noteNorm;
  app.boxFleet[randRod].triggerYScale = 1.0;
  app.boxFleet[randRod].fade = dur * 60.0; //fps       //fade * app.config.triggerFadeScale;   /// subtract from desired maximum time, scaled to this max
  app.boxFleet[randRod].fadeStep = 1.0 / app.boxFleet[randRod].fade; // how much to decrement a 1.0-0.0 value over N frames to get to zero

  // console.log(THREE.Math.mapLinear(dur, 0, 5, 0, 1) );
  // TODO: need to calc a number that scales down from 1 to 0 over the right time frame
  // app.config.debug = app.boxFleet[randRod].fade;

  // setTimeout(() => {
  //   app.boxFleet[randRod].material.opacity = 0;
  // }, (dur*1000) * 0.6 );
};


window.onload = app.init;
