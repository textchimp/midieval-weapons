ffmpeg -i file.wav -f segment -segment_time 30 -c copy parts/output%09d.wav
(https://unix.stackexchange.com/questions/280767/how-do-i-split-an-audio-file-into-multiple)

Load a gem in Sonic Pi
(from https://groups.google.com/forum/#!topic/sonic-pi/QgX82sXcHqY)
"puts RUBY_VERSION" in Sonic Pi to see the version of Ruby its using
Make sure you have the same version installed locally, e.g. via RVM
"gem install gemname" to make sure installed
"gem which gemname" to find the path to the installed gem
use with "require_relative", i.e.:
require_relative '/Users/textchimp/.rvm/gems/ruby-2.4.1/gems/colorize-0.8.1/lib/colorize'
(leave out '.rb')

JAVASCRIPT SPREAD ALGORITHM:
let beats = 3, size = 8, spread = [];
for(let i =0; i < size; i++){
  console.log(`${i}: ${i} * ${beats}(${i*beats}) % ${size} = ${(i * beats) % size}, < ${beats} =  ${((i * beats) % size) < beats}`);
   spread.push( ((i * beats) % size) < beats );
}


spread.map( beat => beat ? 'X':'-' ).join(' ');

DRUM SOUNDS:
:tabla_te_m  - nice rim click
:tabla_na    - round thin drum
:bd_boom     - heavy flat muffled bass

STEREO CHANNEL SELECT:

with_fx :sound_out_stereo, output: 3, amp: 0 do
  # all audio routed to 3+4
end

def panner( note, pan[1...127], chan, port="linuxsampler_in_0" )
#  midi_note_on note , vel, channel: chan

```
vr(*arr)      # return a ring of values (for amplitude) / 10
vr(9, 2, 1)   # => (ring 0.9 0.2, 0.1)

def map_range (v, a, b, y, z)

posc(n, chan, vel: note_vel,  dur: d)

# RECEIVE OSC FROM BROWSER:
live_loop :osc do
  type, val = sync "/osc/controls"
  case type
  when 'bpm' then @bpm = val
  when 'scale' then @scl = val; cl "scale:", scalen(val)
  end
end


s =  load_samples "/scratch/watts/"
sample s[note], pan: rrand(-1, 1)
sleep sample_duration(s[note])

tablas = sample_names( :tabla )
sample tablas.choose

drums = load_samples "/Users/textchimp/Documents/hydrogen/drumkits/BigMono/"
# 128:rimshot, 172: lite hihat,
sample drums[128]

---

sample s num_slices: , slice:
onset: pick





DENSE SUBDIVISION:

in_thread do
  density 3 do
    # 3x parent time
  end
end

octs(:c3, 4)
#=> [:c3, :c4, :c5, :c6]

RANDOM:
rand(max)
rand_back(num) - undo random counter, get repeat of last num values

rdist(1) - between -1 and 1

# TRUE random each run
use_random_seed Time.now.usec



glass = [
  :C2, :C3,  :G3, :Eb3,
  :Bb3, :G3, :C4, :Ab3,
  :Eb4, :C4, :G4,  :Eb4,
  # :Bb4, :G4, :C5, :Eb5
  :Bb4, :G4, :C5, :Eb5  #:r, :r
]
```

SYNTHS:

:beep
:blade
:chipbass
:chiplead
:dark_ambience
:dpulse
:dsaw
:dtri
:dull_bell
:fm
:growl
:hollow
:hoover
:mod_beep
:mod_fm
:mod_sine
:mod_tri
:piano
:pluck
:pretty_bell
:prophet
:pulse
:saw
:sine
:square
:subpulse
:supersaw
:tb303
:tech_saws
:tri
:zawa


#### DRUMS

:bass_hit_c
:bass_hard_c
:bass_thick_c
:bass_drop_c
:bass_woodsy_c
:bass_voxy_c
:bass_voxy_hit_c
:bass_dnb_f

:bd_808
:bd_ada
:bd_boom
:bd_fat
:bd_gas
:bd_haus
:bd_klub
:bd_pure
:bd_sone
:bd_tek
:bd_zome
:bd_zum


:drum_bass_soft
:drum_cowbell
:drum_cymbal_closed
:drum_cymbal_hard
:drum_cymbal_open
:drum_cymbal_pedal
:drum_cymbal_soft
:drum_heavy_kick
:drum_roll
:drum_snare_hard
:drum_snare_soft
:drum_splash_hard
:drum_splash_soft
:drum_tom_hi_hard
:drum_tom_hi_soft
:drum_tom_lo_hard
:drum_tom_lo_soft
:drum_tom_mid_hard
:drum_tom_mid_soft)

:elec_triangle
:elec_snare
:elec_lo_snare
:elec_hi_snare
:elec_mid_snare
:elec_cymbal
:elec_soft_kick
:elec_filt_snare
:elec_fuzz_tom
:elec_chime
:elec_bong
:elec_twang
:elec_wood
:elec_pop
:elec_beep
:elec_blip
:elec_blip2
:elec_ping
:elec_bell
:elec_flip
:elec_tick
:elec_hollow_kick
:elec_twip
:elec_plip
:elec_blup

:perc_bell
:perc_snap
:perc_snap2
:perc_swash
:perc_till

:tabla_tas1
:tabla_tas2
:tabla_tas3
:tabla_ke1
:tabla_ke2
:tabla_ke3
:tabla_na
:tabla_na_o
:tabla_tun1
:tabla_tun2
:tabla_tun3
:tabla_te1
:tabla_te2
:tabla_te_ne
:tabla_te_m
:tabla_ghe1
:tabla_ghe2
:tabla_ghe3
:tabla_ghe4
:tabla_ghe5
:tabla_ghe6
:tabla_ghe7
:tabla_ghe8
:tabla_dhec
:tabla_na_s
:tabla_re


==============================
SCALES:

diatonic:    
ionian:      
major:
dorian:      
phrygian:    
lydian:      
mixolydian:  
aeolian:     
minor:
locrian:     
hex_major6:  
hex_dorian:  
hex_phrygian:
hex_major7:  
hex_sus:     
hex_aeolian:
minor_pentatonic:   
yu:   
major_pentatonic:   
gong:
egyptian:    
shang:
jiao:
zhi:  
ritusen:     
whole_tone:  
whole:
chromatic:   
harmonic_minor:     
melodic_minor_asc:  
hungarian_minor:    
octatonic:   
messiaen1:   
messiaen2:   
messiaen3:   
messiaen4:   
messiaen5:   
messiaen6:   
messiaen7:   
super_locrian:      
hirajoshi:   
kumoi:
neapolitan_major:   
bartok:      
bhairav:     
locrian_major:      
ahirbhairav:
enigmatic:   
neapolitan_minor:   
pelog:
augmented2:  
scriabin:    
harmonic_major:     
melodic_minor_desc:
romanian_minor:     
hindu:
iwato:
melodic_minor:      
diminished2:
marva:
melodic_major:      
indian:      
spanish:     
prometheus:  
diminished:  
todi:
leading_whole:      
augmented:   
purvi:
chinese:     
lydian_minor:

========================
========================
CHORDS:

1    
5    
+5   
m+5  
sus2
sus4
6    
m6   
7sus2
7sus4
7-5  
m7-5
7+5  
m7+5
9    
m9   
m7+9
maj9
9sus4
6*9  
m6*9
7-9  
m7-9
7-10
9+5  
m9+5
7+5-9
m7+5-9      
11   
m11  
maj11
11+  
m11+
13   
m13  
add2
add4
add9
add11
add13
madd2
madd4
madd9
madd11      
madd13      
major
M    
minor
m    
major7      
dom7
7    
M7   
minor7      
m7   
augmented   
a    
diminished  
dim  
i    
diminished7
dim7
i7   
