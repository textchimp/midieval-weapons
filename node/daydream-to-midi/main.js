const easymidi = require('easymidi'),
  daydream     = require('./daydream-node')(),  // requires 'noble'
  argv         = require('minimist')(process.argv.slice(2)),
  readline     = require('readline');

// console.log(easymidi.getOutputs());

const ccMap = {
  xOri: {
    cc: 1,
    min: -1,
    max: 1
  },
  yOri: {
    cc: 2,
    min: -3.14,
    max: 3.14
  },
  zOri: {
    cc: 3,
    min: -1,
    max: 1
  },
  xTouch: {
    cc: 4,
    min: 0,
    max: 1
  },
  yTouch: {
    cc: 5,
    min: 0,
    max: 1
  }
};

const midiPort =  argv.p || 'LinuxSampler_in_0';
const channel  = (argv.c || 1) -1;

const readings = argv._.length ?  argv._ : ['xOri'];
readings.forEach( r => {
  if( !Object.keys(ccMap).includes(r) ){
    console.log(`ERROR: bad reading name '${r}'`);
    process.exit(1);
  }
});

console.log('Sending values for: ', readings.join(', '));

console.log(`Port: ${midiPort}`);
console.log(`Channel: ${channel+1}`);

const output = new easymidi.Output(midiPort);

const prevData = {
  xOri: null
};

const map_range = (v, a, b, y, z, clamp=true) => {
  if( clamp ){
    v = Math.min(v, b); // clamp max
    v = Math.max(v, a); // clamp min
  }
  const norm = (v - a) / parseFloat(b - a)
  return norm * (z - y) + y
};


console.log('Please press HOME button on controller to connect...');


daydream.onStateChange( data => {
  // output whole data object using JSON.stringify and readline library
  // (i.e. overwrite output instead of appending)
  let lineJump = 0;
  if( argv.D ){
    // full debug output
    lineJump = 20;
    readline.clearScreenDown(process.stdout);
    process.stdout.write(JSON.stringify(data, null, 2));
  }
  // send each readings
  readings.forEach( key => {
    const params = ccMap[key];
    const value = Math.ceil( map_range(data[key], params.min, params.max, 1, 127) );
    if( value !== prevData[key] ){
      output.send('cc', { controller: params.cc, value, channel });
      prevData[key] = value;
    }
    if(argv.d) process.stdout.write(`\n${key}: ${data[key]}, mapped: ${value}             `);
    lineJump++;
  });

  if( argv.d ){
    readline.moveCursor(process.stdout, null, -lineJump);
    readline.cursorTo(process.stdout, 0);
  }

});
