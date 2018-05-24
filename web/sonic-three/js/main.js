var app = app || {};

app.step = 0;
// app.cameraPosIndex = 0;
// app.numParticles = 100000;
// app.particleDistribution = 600;

app.controller = {
  rotationSpeed: 0.02,
  bouncingSpeed: 0.00,
  velocityScale: 1,
  xSize: 100,
  boomDec: 0.1,
  xRot: 0.05,
  debug: "1"
};

app.init = function(){

  app.gui = new dat.GUI();
  app.gui.add( app.controller, 'rotationSpeed', 0, 1 );
  app.gui.add( app.controller, 'bouncingSpeed', 0, 2 );
  app.gui.add( app.controller, 'velocityScale', -10, 10 );
  app.gui.add( app.controller, 'xSize', 10, 500 );
  app.gui.add( app.controller, 'boomDec', 0, 0.2 );
  app.gui.add( app.controller, 'xRot', 0, 0.2 );
  app.gui.add( app.controller, 'debug').listen();

  app.scene = new THREE.Scene();

  app.width = window.innerWidth;
  app.height = window.innerHeight;
  app.camera = new THREE.PerspectiveCamera(60, app.width/app.height, 0.1, 3000);

  // Position our camera in the 3D scene
  app.camera.position.x = -30;
  app.camera.position.y = 40;
  app.camera.position.z = 30;
  // Tell the camera what to look at, in this case the center of the scene: (0, 0, 0)
  app.camera.lookAt( app.scene.position );


  app.renderer = new THREE.WebGLRenderer();
  app.renderer.setSize( app.width, app.height ); // Set the size of the rendered canvas (full screen for us)
  // app.renderer.setClearColor( 0x000000 ); // background colour

  app.controls = new THREE.OrbitControls( app.camera, app.renderer.domElement );

  document.getElementById('output').appendChild( app.renderer.domElement );

  app.axes = new THREE.AxesHelper( 40 );
  app.scene.add( app.axes );

  // app.spotlight = app.createSpotlight();
  // app.scene.add( app.spotlight );

  app.ambient = new THREE.AmbientLight( 0xFFFFFF );
  app.scene.add( app.ambient );

  // app.plane = app.createPlane();
  // app.scene.add( app.plane );

  app.cubes = [];
  for( let i = 0; i < 1; i++ ){
    let x = Math.random() * 100 - 50;
    let y = Math.random() * 100 - 50;
    let z = Math.random() * 100 - 50;
    let cube = app.createCube( x, y, z );
    app.cubes.push( cube );
    app.scene.add( cube );
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
