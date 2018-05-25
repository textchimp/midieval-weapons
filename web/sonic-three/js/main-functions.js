var app = app || {};

app.boom = 0;

app.osc = {
  // DEBUG: true,
  // DATA: true,
  data: {},
  setData: function(path, args){
    if(this.DEBUG){
      console.log(path, args);
      console.log(this.data || null);
    }
    if(this.DATA){
      this.data[path] = args;
    }
  },

  '/boom': function( args ){
    this.setData('/boom', args);
    app.randomCube(200, {
      x: app.controller.xSize,
      y: app.controller.xSize,
      z: app.controller.xSize
    });
    app.randCube = Math.floor(app.randRange(0, app.cubes.length));
  },

  '/klub': function( args ){
    this.setData( '/klub', args )
    app.boom = 1.0;
  }

};


const o = (path, ind=0) => {
  if(!app.osc.data || typeof app.osc.data[path] === 'undefined') {
    return 0;
  }
  return app.osc.data[path][ind];
};


app.randRange = function(min, max){
  const range = max - min;
  return min + (Math.random() * range);
}

app.randomCube = function( range=100, opts={} ){
  const cube = app.createCube(
    app.randRange(-range, range),
    app.randRange(-range, range),
    app.randRange(-range, range),
    app.randRange(4, 20),
    opts
  );
  cube.boom = 1.0;
  app.cubes.push( cube );
  app.scene.add( cube );
  // console.log('cube', cube);
};

app.createParticleSystem = function(){
  const particles = new THREE.Geometry();

  for( let i = 0; i < app.numParticles; i++ ){
    const x = app.randRange( -app.particleDistribution, app.particleDistribution );
    const y = 100; //app.randRange( -app.particleDistribution, app.particleDistribution );
    const z = app.randRange( -app.particleDistribution, app.particleDistribution );

    const particle = new THREE.Vector3(x, y, z);

    particle.vx = 0; //app.randRange(-0.2, 0.2);
    particle.vy = 0; //app.randRange(-0.2, 0.2);
    particle.vz = 0; //app.randRange(-0.2, 0.2);

    particles.vertices.push( particle );
  }

  const particleMaterial = new THREE.PointsMaterial({
    color: 0xFFFFFF,
    size: 20,
    map: THREE.ImageUtils.loadTexture("img/snowflake.png"),
    blending: THREE.AdditiveBlending,
    transparent: true,
    alphaTest: 0.5
  });

  const particleSystem = new THREE.Points( particles, particleMaterial );

  return particleSystem;
};

app.createPlane = function(){

  const planeGeometry = new THREE.PlaneGeometry( 120, 20 );
  const planeMaterial = new THREE.MeshLambertMaterial({ color: 0xCFD8DC });
  const plane = new THREE.Mesh( planeGeometry, planeMaterial );

  plane.rotation.x = -0.5 * Math.PI;   // don't ask, it's because of math
  plane.position.x = 15;
  plane.position.y = 0;
  plane.position.z = 0;
  // plane.receiveShadow = true;

  return plane;
};

app.createCube = function(x, y, z, size=4, opts={}){

  const cubeGeometry = new THREE.BoxGeometry(
    (opts && opts.x) || size,
    (opts && opts.y) || size,
    (opts && opts.z) || size,
  );
  const cubeMaterial = new THREE.MeshLambertMaterial({
    // color: 0xFF8F00,
    // map: THREE.ImageUtils.loadTexture("img/s.png"),
    wireframe: false,
    transparent: true,
    opacity: 0.5
  });

  const cube = new THREE.Mesh( cubeGeometry, cubeMaterial );
  cube.position.set( x, y, z );

  cube.userData.original = {x,y,z};
  cube.userData.sin = Math.random();

  cube.boom = 1.0;

  // cube.castShadow = true;
  cube.material.color.setHSL(Math.random(), 1.0, 0.5 );

  return cube;
};

app.createSphere = function(){
  const sphereGeometry = new THREE.SphereGeometry( 30, 40, 40);
  const sphereMaterial = new THREE.MeshLambertMaterial({
    color: 0xFFFFFF,
    wireframe: false,
    side: THREE.DoubleSide,
    map: THREE.ImageUtils.loadTexture("img/earth.jpg")
  });

  const sphere = new THREE.Mesh( sphereGeometry, sphereMaterial );
  sphere.position.set(0, 0, 0);
  // sphere.castShadow =  true;

  return sphere;
};


app.createSpotlight = function(){

  const spotlight = new THREE.SpotLight( 0xFFFFFF );
  spotlight.position.set( -10, 60, 10 );
  // spotlight.castShadow = true;
  // spotlight.shadow.mapSize.width = 2048;
  // spotlight.shadow.mapSize.height = 2048;

  return spotlight;
};


app.createSpline = function( numLines ){
  const randomPoints = [];
  for( let i = 0; i < numLines; i++ ){
    randomPoints.push(new THREE.Vector3(
      Math.random() * 100 - 50,
      Math.random() * 100 - 50,
      Math.random() * 100 - 50
    ));
  }
  randomPoints.push( randomPoints[0] );  // close the spline into a loop

  return new THREE.CatmullRomCurve3( randomPoints );  // THREE.SplineCurve3

};


app.createLineFromSpline = function( spline ){
    const lineMaterial = new THREE.LineBasicMaterial({ color: 0xFF00F0 });
    const lineGeometry = new THREE.Geometry();
    const splinePoints = spline.getPoints(10000);

    for( let i = 0; i < splinePoints.length; i++ ){
      lineGeometry.vertices.push( splinePoints[i] );
    }

  return new THREE.Line( lineGeometry, lineMaterial );
};


app.animate = function(){

  // app.cameraPosIndex++;
  // if( app.cameraPosIndex > 10000){
  //   app.cameraPosIndex = 0;     // start again at the beginning
  // }
  //
  // const camPos = app.spline.getPoint( app.cameraPosIndex / 3000 );
  // const camRot = app.spline.getTangent( app.cameraPosIndex / 3000 );
  // app.camera.position.set( camPos.x, camPos.y, camPos.z );
  // app.camera.rotation.set( camRot.x, camRot.y, camRot.z );
  // // app.camera.lookAt( app.spline.getPoint( (app.cameraPosIndex+1) / 3000) );
  // app.camera.lookAt( app.scene.position );
  //

  app.stats.update();

  // for( let i = 0; i < app.cubes.length; i++ ){
  //   let cube = app.cubes[i]
  //   cube.rotation.x += app.controller.rotationSpeed;
  //   cube.rotation.y += app.controller.rotationSpeed;
  //   cube.rotation.z += app.controller.rotationSpeed;
  // }

  // app.animateParticles();


  app.animateCubes();

  app.step += app.controller.bouncingSpeed; // increment step counter

  // app.sphere.position.x = 20 + (10 * Math.cos(app.step));
  // app.sphere.position.y =  4 + (10 * Math.abs(Math.sin(app.step)));
  // app.sphere.rotation.y += app.controller.rotationSpeed;

  app.renderer.render( app.scene, app.camera );
  requestAnimationFrame( app.animate );
};

app.resetCubesScale = function(){
  app.cubes.forEach( c => c.scale.set(1,1,1) );
  // for( let i = 0; i < app.cubes.length; i++ ){
  //   const cube = app.cubes[i];
  //   cube.scale.set(1,1,1);
  // }
};


app.animateCubes = function(){

  // app.controller.debug = app.boom;

  /******** this looks greeeeat with the growing scale  *******/
  // for( let i = 0; i < app.cubes.length; i++ ){
  //   const cube = app.cubes[i];
  //   cube.geometry.scale( 1.2, 1, 1 ); // using scale() will keep shrinking/growing the scale on successive calls
  // }

  // if(app.boom === 1.0){
  //   for( let i = 0; i < app.cubes.length; i++ ){
  //     app.cubes[i].geometry.scale(1, 1, 1);
  //   }
  // } else
    // app.cubes.forEach( c => c.scale.set(2,1,1) );

    if(app.boom > 0.0 ) app.boom -= app.controller.boomDec;

    // if(Math.random() > 0.5)
    app.controller.debug = parseFloat(app.boom);

    for( let i = 0; i < app.cubes.length; i++ ){
      // const c = app.cubes[app.randCube];
      const c = app.cubes[i];
      // if( c ) {

        if( app.boom >= 0.0 ){
        // if(i == 0) app.controller.debug = c.scale.x;
        // app.controller.debug = app.cubes.length
        // if(c.scale.x < 2.0){
          // c.geometry.scale( 1.2,  0.9, 0.9 );

          c.scale.set(app.boom, app.boom, app.boom);
          // c.scale.set(c.boom, c.boom, c.boom);

          // if(app.boom < 0.1) c.scale.set(0,0,0);
          // c.boom += 0.01;

          // }
          // c.rotation.z += app.controller.xRot;
          c.rotation.y += app.controller.xRot;
        }
        // else {
        //   // c.scale.set(1, 1, 1);
        // }

        app.cubes[i].userData.sin += 0.1 * app.controller.bouncingSpeed;
        app.cubes[i].position.y = app.cubes[i].userData.original.y + (Math.sin(app.cubes[i].userData.sin) * app.controller.rotationSpeed * 100.0);

        // app.cubes[i].scale.set( app.controller.velocityScale, app.controller.velocityScale, 1 );

    // app.cubes.forEach(function(c){
    //   c.scale.set(1.1,1,1);
    // });
      // if(i == 0) console.log({old: cube.scale.x, new: cube.scale.x * (1.0 - app.boom)});
        // cube.scale.x * (1.0 - app.boom) + 0.0001,
        // cube.scale.y * (1.0 - app.boom) + 0.0001,
        // cube.scale.z * (1.0 - app.boom) + 0.0001,
      // );
    // }//for

      // } // if(c)

    }//for

};
//
// app.animateCubes = function(){
//
//   // app.controller.debug = app.boom;
//
//   /******** this looks greeeeat with the growing scale  *******/
//   // for( let i = 0; i < app.cubes.length; i++ ){
//   //   const cube = app.cubes[i];
//   //   cube.geometry.scale( 1.2, 1, 1 ); // using scale() will keep shrinking/growing the scale on successive calls
//   // }
//
//   // if(app.boom === 1.0){
//   //   for( let i = 0; i < app.cubes.length; i++ ){
//   //     app.cubes[i].geometry.scale(1, 1, 1);
//   //   }
//   // } else
//     // app.cubes.forEach( c => c.scale.set(2,1,1) );
//     for( let i = 0; i < app.cubes.length; i++ ){
//       const c = app.cubes[i];
//       if ( app.boom >= 0.0 ){
//         // if(i == 0) debugger;
//         // if(i == 0) app.controller.debug = c.scale.x;//app.controller.debug = [c.scale.x, c.scale.y, c.scale.z];
//         // app.controller.debug = app.cubes.length
//         // if(c.scale.x < 2.0){
//           // c.geometry.scale( 1.2,  0.9, 0.9 );
//           c.scale.set(app.boom, 1, 1);
//           // if(app.boom < 0.1) c.scale.set(0,0,0);
//           c.boom += 0.5;
//
//         // }
//       }
//     // app.cubes.forEach(function(c){
//     //   c.scale.set(1.1,1,1);
//     // });
//       // if(i == 0) console.log({old: cube.scale.x, new: cube.scale.x * (1.0 - app.boom)});
//         // cube.scale.x * (1.0 - app.boom) + 0.0001,
//         // cube.scale.y * (1.0 - app.boom) + 0.0001,
//         // cube.scale.z * (1.0 - app.boom) + 0.0001,
//       // );
//     // }//for
//
//       c.rotation.z += app.controller.xRot;
//       c.rotation.y += app.controller.xRot;
//     }
//
// };


app.animateParticles = function(gx, gy, gz){
  const vertices = app.particleSystem.geometry.vertices;

  for( let i = 0; i < vertices.length; i++ ){
    const vert = vertices[i];

    //   if( vert.y < -app.particleDistribution ){  // y < -300
  //     vert.y = app.randRange(-app.particleDistribution, app.particleDistribution);      // y = 300
  //   }
  //   vert.y -= app.controller.rotationSpeed; // 0.02

  // Yo Newton
    const distSquared = (vert.x*vert.x) + (vert.y*vert.y) + (vert.z*vert.z);

    if(distSquared > 2.0){
      const force = (10.0 / distSquared) * -0.02;

      vert.vx += force * vert.x;
      vert.vy += force * vert.y;
      vert.vz += force * vert.z;
    }

    vert.x += vert.vx * app.controller.velocityScale;
    vert.y += vert.vy * app.controller.velocityScale;
    vert.z += vert.vz * app.controller.velocityScale;

  }

  // app.particleSystem.rotation.y -= 0.002;

  app.particleSystem.geometry.verticesNeedUpdate = true;
};

app.keypress = function(ev){
  console.log('keyCode', ev.keyCode);
  switch( ev.keyCode ){
    case 32: // space
      app.randomCube(200, {
        x: app.controller.xSize,
        y: app.controller.xSize,
        z: app.controller.xSize
      });
      break;
    case 13: // enter
      app.cubes.forEach( c => app.scene.remove(c) );
      app.cubes = [];
      break;
  }
}

app.resize = function(){
  app.width = window.innerWidth;
  app.height = window.innerHeight;

  app.camera.aspect = app.width / app.height;
  app.camera.updateProjectionMatrix();

  app.renderer.setSize(app.width, app.height);
}

app.addStats = function(){
  const stats = new Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';

  document.getElementById('stats').appendChild(stats.domElement);

  return stats;
};
