// Daydream to MIDI bridge

// Usage:
// node main.js -d -c 1 -p 'IAC Driver Bus 1'  xOri yOri isAppDown:zOri xTouch yTouch
//
// -p MIDI_PORT (default 'IAC Driver Bus 1')
// -c CHANNEL
// -d  (enable debugging output)
//

// CURRENT COMMAND:
// loop node /scratch/midieval-weapons/node/daydream-to-midi/main.js -c 1 yOri isClickDown isVolPlusDown isVolMinusDown --osc --calibrate

//loop:
// while true; do node main.js -d -c 1 -p 'IAC Driver Bus 1'  xOri yOri isAppDown:zOri isHomeDown:yOri  xTouch yTouch ; sleep 1; done

// Amp panning control:
// zOri:        1.4 (pointing at tube amp) ... 0 (halfway) ............ 1.0 (pointing at old amp)
// xOri & yOri: 0 ..................         2   (jump to) -2.........
//
//       But they drift!!! how to reset?
//
// Chrome bar graph vis:
// /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --app=file:///scratch/midieval-weapons/web/bar-graph-live-data-vis/index.html


const OSC_REMOTE_HOST = "0.0.0.0";
const OSC_REMOTE_PORT = 57121; //argv._[0] || (SONICPI ? "4559" : "4567");
const EVERY_NTH = 2;
let counter = 0;
let modeCounter = 1;

const easymidi = require('easymidi'),
  daydream     = require('./daydream-node')(),  // requires 'noble'
  argv         = require('minimist')(process.argv.slice(2)),
  osc          = require('osc'),
  readline     = require('readline');

// for catching keypresses
readline.emitKeypressEvents(process.stdin);
process.stdin.setRawMode(true);

process.stdin.on('keypress', (str, key) => {
  // if (key.ctrl && key.name === 'c') {
  //   process.exit();
  // } else {
  //
  // }
  if(key.name === 'd') {
    argv.D = !argv.D;
  } else if( parseInt(key.name) >= 0 && parseInt(key.name) <= 9 ){
    // if(key.name === 'd') {
    console.log(key);
    modeCounter = parseInt(key.name);
    setMidiCC( modeCounter );
  } else {
    process.exit(1); // signal error code (lets 'loop' bash fn know to stop looping)
  }
});

const yOriMidiSends = {
  1: [102, 'Pan'],
  2: [119, 'Tube Dist'], // Top rightmost
  3: [109, 'Granular Scatter'], // Bottom rightmost
  4: [107, 'Reverb'], // Bottom 2nd from right
  5: [102, 'Pan'],
  6: [102, 'Pan'],
  7: [102, 'Pan'],
  8: [102, 'Pan'],
  9: [102, 'Pan'],
};


const setMidiCC = num => {
  if(!(num in yOriMidiSends)) throw new Error(`No such mapping ${num}`);

  const [cc, label] = yOriMidiSends[num];
  ccMap.yOri.cc = cc;
  console.log(`YOri MIDI: ${label} (${num})`);
  oscSendString('/daydream/mode-change', `${label} (${num})`);
};

const oscSendString = (path, string) => {
  if( argv.osc ){
    udpPort.send({ address: path, args: [{ type: 's', value: string}] }, OSC_REMOTE_HOST, OSC_REMOTE_PORT);
  }
};

// console.log(easymidi.getInputs());
// console.log(easymidi.getOutputs());

const ccMap = {
  isVolPlusDown: {
    cc: 123,
    onPress( data ){
      modeCounter = (modeCounter % 9)  +  1;
      setMidiCC( modeCounter );
    }
  },
  isVolMinusDown: {
    cc: 124,
    onPress( data ){
      modeCounter = (modeCounter <= 1) ?  9  :  modeCounter - 1;
      setMidiCC( modeCounter );
    }
  },
  isClickDown: {
    cc: 100,
    onPress( data ){
      console.log('PRESS!', data['yOri']);
      ccMap.yOri.calibratedOffset = data['yOri'];
    }
  },
  xOri: {
    cc: 1,
    // min: 1,
    // max: -1,
    min: -1,
    max: 1,
    // calc(val){
    //   return  128 -    Math.ceil( map_range(val, this.min, this.max, 1, 127) );
    // }
  },
  yOri: {
    cc: 2,
    // min: -3.14,
    // max: 3.14
    min: -2.1,
    max: 2.1,
    calibratedOffset: null,
    // calc: data => Math.random(),
  },
  zOri: {
    cc: 3,
    // min: -2,
    // max: 2
    // When sideways (on guitar):
    min: 0,
    max: 1.4

    // calc(val){
    //   return Math.ceil( map_range(val, this.min, this.max, 1, 127) );
    //   console.log(`custom ${val}`);
    //   return val * 0.5;
    // }
  },
  xTouch: {
    cc: 4,
    min: 0,
    max: 1,
    ignoreZero: true
  },
  yTouch: {
    cc: 5,
    min: 0.1,
    max: 1,
    ignoreZero: true
  },
  xAcc: {
    cc: 6,
    min: -20,
    max: 20,
    threshold: 8
  },
  yAcc: {
    cc: 7,
    min: -20,
    max: 20,
    // offset: -10.1,
    threshold: 12,
  },
  zAcc: {
    cc: 8,
    min: -20,
    max: 20
  },

};

let udpPort = null;
if( argv.osc ){
  console.log('Sending OSC...');
  // Bind to a UDP socket to listen for incoming OSC events.
  udpPort = new osc.UDPPort({
    // OSC RECEIVE (listening) port:
    localAddress: "0.0.0.0",
    localPort:  575757, // || process.argv[2]

    // OSC SEND (forwarding) port:
    remoteAddress: "127.0.0.1",
    remotePort: 57121 //WEBSOCKETS_TO_OSC_SEND_PORT // process.argv[3] ||
  });
  udpPort.open();
  setMidiCC( modeCounter ); // send initial mode message
}

const midiPort =  argv.p || 'IAC Driver Bus 1' //'LinuxSampler_in_0';
const channel  = (argv.c || 1) - 1;

const readings = argv._.length ?  argv._ : ['xOri'];
readings.forEach( (r,i) => {
  if(r.includes(':')){
    // Sending of reading will be conditional on the cond
    const [cond, key] = r.split(':');
    console.log(cond, key);
    ccMap[key].cond = cond;
    readings[i] = key;
    r = key;
  }
  if( !Object.keys(ccMap).includes(r) ){
    console.log(`ERROR: bad reading identifier '${r}'`);
    process.exit(1);
  }
});

// console.log(ccMap);

console.log('Sending values for: ', readings.join(', '));

console.log(`Port: ${midiPort}`);
console.log(`Channel: ${channel+1}`);

if( argv.calibrate ){
  console.log('Using calibration.');
}

const output = new easymidi.Output(midiPort);

const prevData = {};

const map_range = (v, a, b, y, z, clamp=true) => {
  if( clamp ){
    v = Math.min(v, b); // clamp max
    v = Math.max(v, a); // clamp min
  }
  const norm = (v - a) / parseFloat(b - a)
  return norm * (z - y) + y
};


console.log('Please press HOME button on controller to connect...');

const shouldSendReading = (data, key, val, params) => {
  return val !== prevData[key] // data has changed
    && (!params.ignoreZero || data[key] > 0)  // check touchpad values, which reset to zero
    && (!params.cond || data[params.cond]) // check for command line button condition for data (ie 'isClickDown:yOri')
    && (!params.threshold || data[key] > params.threshold); // only send greater than threshold values for acceleration values
};

daydream.onStateChange( data => {
  let lineJump = 0;
  if( argv.D ){
    // full debug output
    lineJump = 20;
    readline.clearScreenDown(process.stdout);
    // output whole data object using JSON.stringify and readline library
    // (i.e. overwrite output instead of appending)
    process.stdout.write(JSON.stringify(data, null, 2));
  }

  // send each readings
  readings.forEach( key => {
    const reading = data[key];
    const params = ccMap[key];
    let calibratedReading = null;
    const offset = params.calibratedOffset || 0.0;
    const previous = prevData[key];


     if( 'onPress' in params ){
       // click Event - run onPress if just pressed
       if( reading  && !prevData[key] ){
         params.onPress( data );
       }
       prevData[key] = reading;
       return;
     } else if( argv.calibrate ){
       // Not a click event, so calibrate if command-line is set
       calibratedReading = reading - offset;
     } else {
       calibratedReading = reading; // don't use offset
     }

    // const offset = params.offset || 0;
    let value;
    if('calc' in params){
      value = params.calc(calibratedReading, reading); // run custom calc function - return false to skip sending
    } else {
      value = Math.ceil( map_range(calibratedReading, params.min, params.max, 1, 127) );
    }
     // value !== false &&

     // if( previous && previous - value > 20
     //     && (key !== 'xTouch' && key !== 'yTouch') ){
     //   // console.log(`return on ${key} = ${value}, diff=${prevData[key] - value}`, prevData);
     //   return; // Ignore a reading whose value is too large a jump from the last
     // }


     const oneInN = counter++ % EVERY_NTH === 0;

    if( shouldSendReading(data, key, value, params) && oneInN ){

      output.send('cc', { controller: params.cc, value, channel });  // send MIDI
      prevData[key] = value;

      if(argv.d){
         process.stdout.write(`\n${key}: ${calibratedReading}, mapped: ${value} (thresh:  ${calibratedReading} > ${params.threshold} )            `);
      }
      lineJump++;

      if( argv.osc ){
        // console.log('send', `/daydream/${key}`, calibratedReading, value);
        udpPort.send({
            address: `/daydream/${key}`,
            args:[
              {type: 'f', value: calibratedReading},
              {type: 'f', value: value},
              {type: 'f', value: reading},
            ]
        }, OSC_REMOTE_HOST, OSC_REMOTE_PORT);
      } // OSC send

    } // shouldSendReading

  });

  if( argv.d ){
    readline.moveCursor(process.stdout, null, -lineJump);
    readline.cursorTo(process.stdout, 0);
  }

});

// this is the nice one for guitar samples?

// Sonic Pi:
// use_random_seed Time.now.usec
//
// run_file '/scratch/midieval-weapons/sonicpi/lib-touchosc.pi.rb'
//
// ##| sams = load_samples ""
// sams  = load_samples '~/Documents/audio/', /gtr-(?!.*slsess).*/
//
// ##| s = sams.choose
//
// s = sams[11]
// ##| s = "/Users/textchimp/Downloads/watts1.wav"
//
// set(:point, 64)
// set(:xtouch, 1)
// set(:ytouch, 20)
//
// live_loop :midi do
//   cc_map = {1 => :twist, 2 => :rotate, 3 => :point, 4 => :xtouch, 5 => :ytouch }
//   cc, val = sync "/midi/iac_driver_bus_1/0/1/control_change"
//   set(cc_map[cc], val)
//   ##| sample s, onset:val #, release: 0.1
//   ##| sleep sample_duration(s)
// end
//
// live_loop :sam do
//   slices = map_range(get(:ytouch), 1, 127, 1, 100)
//   slice = map_range(get(:twist), 1, 127, 1, slices)
//   zzz = sample_duration(s) / slices.to_f
//   sample s, num_slices: slices, slice: slice,
//     attack: get(:xtouch)/127.0,
//     release: 0.01
//   ##| puts (get(:ytouch).to_f / 127.0)
//   cl get(:point)
//   sleep 0.01 + get(:point) / 127.0
// end
//
