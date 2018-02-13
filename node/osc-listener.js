const osc = require('osc'),
  readline = require('readline'),
  keypress = require('keypress');
  argv = require('minimist')(process.argv.slice(2));

const SCROLL = argv.s;    // boolean: srcoll mode (simple output, no readline screen layout)
const BARS = argv.b;      // boolean: show bar graphs instead of numbers
const BAR_LENGTH = 30;
const DURATION = argv.d;  // duration to show each message in ms
const TRUNCATED = argv.t  // show only two decimal places

if( argv._.length < 1){
  console.log(`Usage: node ${__filename.split('/').pop()} PORT [filter_string]`);
  console.log('\t-s  simple scroll mode (no readline formatted output)');
  console.log('\t-b  bar graph mode');
  console.log('\t-t  truncated floats mode (2 decimal places)');
  console.log('\t-d NUM  how long to show each message');
  process.exit(1);
}

// keypress.enableMouse(process.stdout);
// process.stdin.on('mousepress', function (info) {
//   console.log('got "mousepress" event at %d x %d', info.x, info.y);
// });

keypress(process.stdin);
process.stdin.setRawMode(true);
process.stdin.resume();

process.stdin.on('keypress', function (ch, key) {
  process.stdout.write( "\n" );
  process.exit(0);
});

readline.cursorTo(process.stdout, 0, 0);
readline.clearScreenDown(process.stdout);

// You can optionally show only lines of output which match a filter string
const filter =  argv._[1] || false;

// Create an osc.js UDP Port listening on port 57121.
const udpPort = new osc.UDPPort({
    localAddress: "0.0.0.0",
    localPort:  argv._[0],
    metadata: true
});

let paths = {};
let longestPath = 0;
let longestArgCount = 0;
let longestArgs = []; // keep track of the longest argument at each position, for column-aligned printing

// let lineCounter = 0;

udpPort.on("message", function( msg ){

  if( SCROLL ){
    let str = msg.address + '  ' + msg.args.reduce( (acc, val) => acc + '  ' + val.value, [] );
   if( filter ){
     if( str.indexOf(filter) >= 0 ){
       console.log(str);
     }
   } else {
     console.log(str);
   }
   return;
  }

  paths[msg.address] = [ msg.args, new Date().getTime() ];  // add to running list of paths

  longestArgCount = Math.max(longestArgCount, msg.args.length);
  longestPath = Math.max(longestPath, msg.address.length);

  // Each time we receive a new message, we clear the screen and print them all!

  if(Object.values(paths).length) {

  readline.cursorTo(process.stdout, 0, 0);
  readline.clearScreenDown(process.stdout);

  // if(Object.values(paths).length !== lineCounter) debugger;

  for(let path in paths){

    // Apply text match filter if set (NOTE: this only matches paths, not arg values)
    if(filter && path.indexOf(filter) < 0 ){
      continue;
    }

    if( DURATION && (new Date().getTime() - paths[path][1]) > DURATION ){
      // TODO: reset the longestArgCount/longestArg values somehow?
      delete paths[path];
      continue;
    }

    process.stdout.write( path );

    let col = longestPath + 2;
    readline.cursorTo(process.stdout, col); // align start of args output to end of longest path

    // loop over args and output them in nice columns for readability
    paths[path][0].forEach( (arg, i) => {

        let argStr = TRUNCATED && arg.type === 'f' ?
          arg.value.toFixed(2).toString() :
          arg.value.toString();

        longestArgs[i] = Math.max(longestArgs[i] || 0, argStr.length); // keep track of longest
        let longest = longestArgs[i];

        if ( BARS && (arg.type === 'f') && arg.value > 0 && arg.value <= 1 ) {
          longest = BAR_LENGTH;
          let barLength = parseInt(longest * arg.value);
          process.stdout.write( Array(barLength).fill('\u2588').join('') )
        } else {
          process.stdout.write( argStr );
        }

        col += longest + 2; // set next column start from longest arg at this position
        readline.cursorTo(process.stdout, col);
    });

    readline.cursorTo(process.stdout, 0);
    process.stdout.write( "\n" );

  } // each path

}
  // lineCounter = Object.values(paths).length;

});

// Open the socket.
udpPort.open();
