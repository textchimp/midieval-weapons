if( 'bluetooth' in navigator === false ){
	// alert("This browser doesn't support Web Bluetooth.");
  document.getElementById('button').style.display = 'none';
}


// textarea.style.display = 'none';
textarea.style.fontSize = '9pt';

var daydreamControllerInit = function(){

  var cont = new DaydreamController();

  cont.onStateChange( function ( state ) {

    textarea.textContent = JSON.stringify( state, null, '\t' );


    var angle = Math.sqrt( state.xOri * state.xOri + state.yOri * state.yOri + state.zOri * state.zOri );

    state.angle = angle;
    controller = state;

    if ( angle > 0 ) {

      // axis.set( state.xOri, state.yOri, state.zOri )
      // axis.multiplyScalar( 1 / angle );

      // quaternion.setFromAxisAngle( axis, angle );
      //
      // if ( initialised === false ) {
      //   quaternionHome.copy( quaternion );
      //   quaternionHome.inverse();
      //   initialised = true;
      // }

    } else {
      // quaternion.set( 0, 0, 0, 1 );
    }

    /*
    if ( state.isHomeDown ) {

        if ( timeout === null ) {

          timeout = setTimeout( function () {

            quaternionHome.copy( quaternion );
            quaternionHome.inverse();

          }, 1000 );

        }

      } else {

        if ( timeout !== null ) {

          clearTimeout( timeout );
          timeout = null;

        }

      }

      mesh.quaternion.copy( quaternionHome );
      mesh.quaternion.multiply( quaternion );

      button1.material.emissive.g = state.isClickDown ? 0.5 : 0;
      button2.material.emissive.g = state.isAppDown ? 0.5 : 0;
      button3.material.emissive.g = state.isHomeDown ? 0.5 : 0;

      touch.position.x = ( state.xTouch * 2 - 1 ) / 1000;
      touch.position.y = - ( state.yTouch * 2 - 1 ) / 1000;

      touch.visible = state.xTouch > 0 && state.yTouch > 0;
  *******************/

  });

  cont.connect();
}; // click handler, needs to be within this for browser security persmission reasons

button.addEventListener( 'click', daydreamControllerInit );

document.onkeypress = function (e) {
    e = e || window.event; // use e.keyCode
    if( e.key === 'c' ||  e.key === ' ' ){
        daydreamControllerInit();
    } else if( e.key === 'h' ){
      head = !head;
    }
};
