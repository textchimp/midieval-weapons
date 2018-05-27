var app = app || {};

app.step = 0;
// app.cameraPosIndex = 0;
// app.numParticles = 100000;
// app.particleDistribution = 600;

app.NUM_CUBES = 100;

app.controller = {
  rotationSpeed: 0.1,
  bouncingSpeed: 0.50,
  cubeScale: 1,
  xSize: 100,
  boomDec: 0.01,
  xRot: 0.05,
  cameraRot: 0.005,
  debug: "1",
  d2: "d2",
  sliceWidth: 0.5,
  sliceProb: 1.0,
  slicePhase: 0.25,
  paused: false,
  lightColour: { h:1, s:1, v:1 },

};

app.init = function(){

  app.gui = new dat.GUI();
  app.gui.addColor( app.controller, 'lightColour').onChange( val => {
    app.ambient.color.setHSL(val.h, val.s, val.v);
  });
  app.gui.add( app.controller, 'rotationSpeed', 0, 1 );
  app.gui.add( app.controller, 'bouncingSpeed', 0, 2 );
  app.gui.add( app.controller, 'cubeScale', 0, 2 );
  app.gui.add( app.controller, 'xSize', 10, 500 );
  app.gui.add( app.controller, 'boomDec', 0, 0.2 );
  app.gui.add( app.controller, 'xRot', 0, 0.2 );
  app.gui.add( app.controller, 'cameraRot', 0, 0.1 );
  app.gui.add( app.controller, 'debug').listen();
  app.gui.add( app.controller, 'd2').listen();
  app.gui.add( app.controller, 'sliceWidth', 0, 1).onChange( val => {
    app.oscPort.send({
        address: "/controls",
        args: [
          {type: "s", value: 'scale'},
          {type: "f", value: val},
        ]
      });
  });
  app.gui.add( app.controller, 'sliceProb', 0, 1).onChange( val => {
    app.oscPort.send({
        address: "/controls",
        args: [
          {type: "s", value: 'sprob'},
          {type: "f", value: val},
        ]
      });
  });
  app.gui.add( app.controller, 'slicePhase', 0, 1, 0.05).onChange( val => {
    app.oscPort.send({
        address: "/controls",
        args: [
          {type: "s", value: 'sphase'},
          {type: "f", value: val},
        ]
      });
  });


  app.scene = new THREE.Scene();

  app.width = window.innerWidth;
  app.height = window.innerHeight;
  app.camera = new THREE.PerspectiveCamera(60, app.width/app.height, 0.1, 3000);

  // Position our camera in the 3D scene
  app.camera.position.x = -230;
  app.camera.position.y = 310;
  app.camera.position.z = 400;
  // Tell the camera what to look at, in this case the center of the scene: (0, 0, 0)
  app.camera.lookAt( app.scene.position );


  app.renderer = new THREE.WebGLRenderer();
  app.renderer.setSize( app.width, app.height );
  // app.renderer.setClearColor( 0x000000 ); // background colour

  app.controls = new THREE.OrbitControls( app.camera, app.renderer.domElement );

  document.getElementById('output').appendChild( app.renderer.domElement );

  app.axes = new THREE.AxesHelper( 40 );
  app.scene.add( app.axes );

  // app.spotlight = app.createSpotlight();
  // app.scene.add( app.spotlight );

  app.ambient = new THREE.AmbientLight( 0xFFFFFF );
  app.scene.add( app.ambient );

  app.cubes = [];
  for( let i = 0; i < app.NUM_CUBES; i++ ){
    app.randomCube(200, {
      x: app.controller.xSize,
      y: app.controller.xSize,
      z: app.controller.xSize,
      hide: true
    });
    console.log('kube');
  }

  // app.sphere = app.createSphere();
  // app.scene.add( app.sphere );
  // app.spline = app.createSpline( 10 );
  // app.line = app.createLineFromSpline( app.spline );
  // app.scene.add( app.line );
  // app.particleSystem = app.createParticleSystem();
  // app.scene.add( app.particleSystem );

  app.stats = app.addStats();
  app.animate();
};

window.onload = app.init;
window.addEventListener('resize', app.resize);
window.addEventListener('keypress', app.keypress || null);
