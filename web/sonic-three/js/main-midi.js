
var midi = {};


const MIDI_INPUTS = [
  'Launchkey MK2 49 Launchkey MIDI',
  'Launchpad Mini',
  'Scarlett 2i4 USB',
  'TouchOSC Bridge',
  // 'IAC Driver Bus 1'  // can cause feedback
];

const MIDI_OUTPUT = "IAC Driver Bus 1";

const S1 = 41, S2 = 42, S3 = 43, S4 = 44, S5 = 45, S6 = 46 ,S7 = 47, S8 = 48, S9 = 49,
      K1 = 21, K2 = 22, K3 = 23, K4 = 24, K5 = 25, K6 = 26 ,K7 = 27, K8 = 28,
      PITCH = 0, MOD = 1;

var mstate = {
  notes: {},
  sliders: { [S8]: 0.5, [K8]: 0.5, [S9]: 0.5 }, // defaults
  buttons: {}
};

function gotMIDI(m){
  let [cmd, note, vel] = m.data;

  if(DEBUG) console.log('MIDI', {cmd, note, vel});

  // 144 note on   - launchpad also sends 144 when button off, vel 0
  // 128 note off
  // 153/137  - launchkey pad button on/off
  // 176 - launchkey slider values, note 41-48
  // 176 - launchkey knob values, note 21-28
  // 176 - launchkey slider buttons, note val 51-58, vel 127/0
  // 176 - launchkey mod wheel, note 1, vel 0-127
  // 176 - launchkey pitch shift, note 0, vel 0 - [64 default] - 127
  // 176 - launchkey RHS play buttons, note 104, 105 vel 127/0
  // 176 - launchkey RHS buttons, note 112-117, vel 127/0
  // 176 - launchkey LHS track L/R buttons, notes 102,103, vel 127/0


  // check type of MIDI message, and store normalised value in mstate object
  switch(cmd){
    case 144:
    case 128:
    case 153:
    case 137:
    // note ON/OFF
      mstate.notes[note] = vel/127.0;
      // midi.out.send([144, note, vel]);  // TO SEND A NOTE
      break;
    case 176:
    // slider/buttons
      mstate.sliders[note] = vel/127.0;
      break;
  }
  // console.log(mstate.notes, mstate.sliders, mstate.buttons);
}
