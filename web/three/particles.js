var app = app || {};


app.createParticleSystem = function(){

  // Particles are just a collection of vertices in a general-purpose geometry
  var particles = new THREE.Geometry();

  for (var i = 0; i < app.config.numParticles; i++) {

    // split the particles into two sheets!
    if(Math.random() < 0.5){
      var x = 200;
      var y = THREE.Math.randInt(-app.config.particleDistribution, app.config.particleDistribution );
      var z = THREE.Math.randInt(-app.config.particleDistribution, app.config.particleDistribution );
    } else {
      var x = THREE.Math.randInt(-app.config.particleDistribution, app.config.particleDistribution );
      var y = THREE.Math.randInt(-app.config.particleDistribution, app.config.particleDistribution );
      var z = 400;
    }



    // Create a vertex
    var particle = new THREE.Vector3(x, y, z);

    var velRange = 0.9;
    particle.vx = 0; // THREE.Math.randFloat( -velRange, velRange );
    particle.vy = 0; // THREE.Math.randFloat( -velRange, velRange );
    particle.vz = 0; // THREE.Math.randFloat( -velRange, velRange );


    // Add it to our particle system geometry
    particles.vertices.push( particle );
  } // for

  var particleMaterial = new THREE.PointsMaterial({
    color: 0xFFFFFF,
    size: app.config.particleSize,
    map: THREE.ImageUtils.loadTexture("/img/snowflake.png"),
    blending: THREE.AdditiveBlending,
    transparent: true,
    alphaTest: 0.5 // try values like 0 to 0.1 to see effect
  });

  var particleSystem = new THREE.Points( particles, particleMaterial );

  return particleSystem;
};


app.animateParticles = function(){

  var vertices = app.particleSystem.geometry.vertices;

  for (var i = 0; i < vertices.length; i++) {
    var vert = vertices[i];

    // rain effect
    // if( vert.y < -200 ){
    //   vert.y = app.config.particleDistribution + THREE.Math.randInt(-50, 50);
    // }
    // vert.y -= app.config.bouncingSpeed;

    var dist = Math.sqrt( vert.x*vert.x + vert.y*vert.y + vert.z*vert.z )


    if( dist > 10.0 ){
      // only apply gravity if the particle isn't too close to the origin,
      // to prevent too strong an effect
      var force = ( 10.0 / (dist*dist) ) * -app.config.gravityScale;
      vert.vx += force * vert.x;
      vert.vy += force * vert.y;
      vert.vz += force * vert.z;

    }

    vert.x += vert.vx * app.config.velocityScale;
    vert.y += vert.vy * app.config.velocityScale;
    vert.z += vert.vz * app.config.velocityScale;


  } // for

    // app.particleSystem.rotation.y -= app.config.rotationSpeed;

    app.particleSystem.geometry.verticesNeedUpdate = true;
};
