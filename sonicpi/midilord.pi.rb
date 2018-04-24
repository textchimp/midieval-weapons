
# stereo SEND TO 3 & 4 IS ACTIVE

# TODO:
# Where are spread beats happening?
# Accents not matching up with buttons? tick/look mod issue?
# Stereo panning (jumping) - param to set ticks before jump to other channel
# button lights - default values (spread), accent highlights button, pressing off goes back to default values
# (pass in to grid code? or use constructor)


#
# K1 - spread nom 1-denom
# K2 - spread denom 1-16
# K3 - sample 1-max
# K4 - sample alt offset 0.0-1.0
# K5 - sample bank set 1-max
#
#
# S3 - echo mix
# S4 - echo phase
# S5 - krush mix


# how to organise Hydrogen drum samples? esp. multilayered?

# load a gem
require_relative '/Users/textchimp/.rvm/gems/ruby-2.4.1/gems/colorize-0.8.1/lib/colorize'


run_file '/scratch/midieval-weapons/sonicpi/lib-launchpad-buttons.pi.rb'
sleep 0.5

midi_all_notes_off()

# reset board
# midi_raw 176, 0, 0

SPREAD_MAX = 16
DRUM = true
KITS = [
  "/samples/Percussion/",
  "/samples/Grand Piano/",
  "/samples/“Piano/",
  "/samples/Harp/",
  "/Users/textchimp/Documents/hydrogen/drumkits/3355606kit",
  "/Users/textchimp/Documents/hydrogen/drumkits/Audiophob",
  "/Users/textchimp/Documents/hydrogen/drumkits/BJA_Pacific",
  "/Users/textchimp/Documents/hydrogen/drumkits/BigMono",
  "/Users/textchimp/Documents/hydrogen/drumkits/Boss DR-110", #[4]
  "/Users/textchimp/Documents/hydrogen/drumkits/Classic-626",
  "/Users/textchimp/Documents/hydrogen/drumkits/ColomboAcousticDrumkit",
  "/Users/textchimp/Documents/hydrogen/drumkits/ErnysPercussion",
  "/Users/textchimp/Documents/hydrogen/drumkits/Flac_GSCW-1", #[8]
  "/Users/textchimp/Documents/hydrogen/drumkits/Flac_GSCW-2",
  "/Users/textchimp/Documents/hydrogen/drumkits/Gimme A Hand 1.0",
  "/Users/textchimp/Documents/hydrogen/drumkits/K-27_Trash_Kit",
  "/Users/textchimp/Documents/hydrogen/drumkits/Millo_MultiLayered3", #[12]
  "/Users/textchimp/Documents/hydrogen/drumkits/TR808909",
  "/Users/textchimp/Documents/hydrogen/drumkits/YamahaVintageKit",
  "/Users/textchimp/Documents/hydrogen/drumkits/circAfrique v4"
]
KITCOUNT = KITS.length



# TODO: move to launchkey lib
CC = "/midi/launchkey_mk2_49_launchkey_midi/*/*/control_change"
NOTE_ON = "/midi/launchkey_mk2_49_launchkey_midi/*/*/note_on"
NOTE_OFF =  "/midi/launchkey_mk2_49_launchkey_midi/*/*/note_off"
S1 = 41; S2 = 42; S3 = 43; S4 = 44; S5 = 45; S6 = 46 ;S7 = 47; S8 = 48; S9 = 7;
K1 = 21; K2 = 22; K3 = 23; K4 = 24; K5 = 25; K6 = 26 ;K7 = 27; K8 = 28;
PITCH = 0; MOD = 1;

cl @grid

g = @grid[0]  # use first page only

unless defined? @mstate
  @mstate = {}
  @mstate[S1] = 1.0 # lpf
  @mstate[S2] = 0.0 # lpf
  @mstate[S3] = 0.0 # echo mix
  @mstate[S4] = 0.0 # echo phase
  @mstate[S5] = 0.0 # krush mix
  @mstate[S9] = 0.4 # bpm

  @mstate[K1] = 0.5
  @mstate[K2] = 1.0
  @mstate[K3] = 0.94
  @mstate[K4] = 0.0

  @mstate[K5] = 0.5  # sample bank

  @mstate[K6] = 0.0
  @mstate[K7] = 0.5
  @mstate[K8] = 0.5
end


@mstate[S8] = 0.5 # rate 0-2
@mstate[K8] = 0.5


# def m(n, default:, min:, max:)
#   val = @mstate[n] || default || 0.5
#   val unless min.defined? and max.defined?
#   map_range(val, 0, 127, min, max)
# end

def m(n, default:0.5, min:0.0, max:1.0)
  min + (@mstate[n] || default) * (max-min)
end

####################################################################################
@mstate[K2] = 0.2
def spread_buttons
  spread_div = m(K2, min:1, max:SPREAD_MAX).to_i
  spread_nom = m(K1, min:1, max:spread_div).round
  # spread_div = 64
  spreaded = spread(spread_nom, spread_div)

  SPREAD_MAX.times do |n|
    if n < spread_div
      if spreaded[n]
        col = 44
      else
        col = 20
      end
    else
      col = 0
    end
    midi_note_on num_to_lp( n ), vel:col, port: "launchpad_mini" #7
  end
end

spread_buttons()
spread_last = [0, 0]

last_note = 60
last_vel = 30

notes = []
notes_max = m(K2, min:1, max:16).to_i

def modchan
  m(MOD, min: 1, max: 15).to_i
end



with_fx :sound_out_stereo, output: 3, amp: 0 do


with_fx :lpf, slide: 0.02 do |lpf|
    with_fx :distortion, pre_mix: m(S2) do |dist|

      with_fx :krush, pre_mix: m(S5), slide: 0.2 do |krush|
      #   with_fx :octaver, slide: 0.2 do |octaver|
          with_fx :echo, slide: 0.2, mix: m(S3) do |ec|
      #       with_fx :pitch_shift, slide: 0.1 do |pitch|


live_loop :notes do
  note, vel = sync NOTE_ON
  last_note = note
  last_vel = vel
  cl tick%notes_max
  notes[look%notes_max] = [note, vel, modchan]
  # cl [last_note, last_vel]
end

live_loop :mcontrols do
  note,vel = sync CC
  @mstate[note] = vel / 127.0
  cl "%d: %.2f" % [ note, @mstate[note] ]
  control lpf, cutoff:  m(S1, min:0, max:130) if note == S1
  control dist, distort: m(S2, min:0, max:0.999) if note == S2

  control ec, mix: m(S3) if note == S3
  control ec, phase: m(S4), phase_slide:0.5 if note == S4
  control krush, pre_mix: m(S5), slide:0.1 if note == S5

  # control rev, mix:      o(4, 'rev mix', 1)
  # control krush, pre_mix:  o(10, 'krush', 1), res: o('/1/rotary/4', 'k res', 0.999)
  # control octaver, pre_mix: o('/1/rotary/3', 'octvr', 1) #pre_mix:  o(10, 'krush', 1), res: o('/1/rotary/4', 'k res', 0.999)

  # chrom = [:c, :cs, :d, :ds, :e, :f, :fs, :g, :gs, :a, :as, :b]
  # key = o('/1/rotary/5', 'key', chrom.length-1){ |v| note_name(chrom[v.to_i]) }.to_i

  # if note == K2
  #   spread_div = m(K2, max:15)
  #   spread_div.times { |n| midi_note_on num_to_lp( n+1 ), vel: 7 }
  # end

  # puts @mstate # puts param
end

def spread_highlight( arr, current )
  out = arr.map.with_index do |elem, i|
    el = elem ? '1' : '0'
    el = el.green if i == current
    el
  end
  out.join ' '
end

den = 8
# ds = sample_paths "/samples/Percussion/"
ds = sample_paths KITS[0]

live_loop :go do
  n = tick
  cue :beat, n

  ss = m(K2, min:1, max:SPREAD_MAX).to_i
  sf = m(K1, min:1, max:ss).round

  # if n%ss == 0
  #   sample(:elec_wood, amp: 0.2)
  # end

  if [sf, ss] != spread_last
    spread_buttons()
  end
  spread_last = [sf, ss]

  spread_ring = spread(sf, ss)
  cl "spread: #{ spread_highlight(spread_ring.to_a, n%ss) }"


  beat_marker( n % ss, ss )

  use_bpm m(S9, min:20, max:160)
  kit = m(K5, max: KITCOUNT-1).floor
  ds = sample_paths KITS[kit]

  # beatflash =
  # cl "\e[H\e[2J"
  cl "#{sf} / #{ss}, %.1fbpm, [#{look}, mod #{ss} = #{ look%ss }]" % current_bpm

  # ds = sample_names(:bd)
  d = m(K3, max:ds.length).round
  sampoff = m(K4, max:ds.length).round

  cl "#{KITS[kit].split('/').last.green}: #{d}/#{d+sampoff}(+#{sampoff})"
  # cl "#{spread(sf, ss).to_a}".light_blue
  cl notes.to_s.red

  # sf.times do |i|
  #   midi num_to_lp( i ), vel: 7
  #   cl "i: #{i}: #{num_to_lp( i )}"
  #   quot, mod = i.divmod sf
  #   cl "#{i}/#{ss} = #{quot}, #{mod}"
  #   midi_note_on 1 + quot*16 + mod, clr(:wred)
  # end‘’


   # todo: pan look mod, ctrl

   panlook = m(K6, min:1, max: 4)

   amp_add = vr(-5, 5, -2, -5).look

   # seq_or_k8 = [ g[0][look%ss], m(K8, default: 1) ].max
   seq_or_k8 = m(K8, default: 1)

   mnote, mvel, mchan = notes[look%notes_max] #last_note
   # mvel  = last_vel # vr(2,2,5, 2, 2).look,
   pan = -1 + look%panlook  * m(K7)*panlook
   mpan = [1, 127, 64].choose #.ring.look

   # mchan = modchan()

   cl "MIDI[#{modchan}] #{mchan}:#{mnote}, #{mvel} (pan #{mpan})".yellow

   samp =  g[0][look%8] > 0 ? ds[d+sampoff] : ds[d]

  if spread_ring.look
    sample samp,
    pan: pan,
    rate: m(S8, max:2),
    amp: seq_or_k8 + amp_add   # this sets an accent for seq-on notes (row 0), K8 for non-accent amp


    panner(mnote, mpan, mchan)
    midi mnote,
      channel: mchan,
      vel: mvel,
      sustain: 0.8,
      port: "iac_driver_bus_1"

    # sample(:tabla_tun1, amp: 0.2)
    # midi_note_on num_to_lp( n%ss ), vel:55, port: "launchpad_mini"


  end
  # cl "spread: #{spread_ring.look.to_s.red}"

  # sample(:drum_cymbal_pedal, amp: 0.2, sustain: 0.02)

  # amp: [0.8, 0.4, 0.8].ring.look
  # den = rrand_i(4, 9) if look % 12 == 0
  sleep 0.3
end

# cl 123

drums = sample_names :tabla
# drums = sample_paths "/samples/Percussion/"
# drums = sample_paths "/Users/textchimp/Documents/hydrogen/drumkits/BJA_Pacific/"

# sequencer buttons, independent of spread
comment do
  live_loop :drumseq do
    n = sync(:beat).first
    n %= 8
    beat_marker(n)
    offset = m(K6, max:20).round
    g[1..-1].each_with_index do |row, i|
      sample drums[ i + offset ], amp: row[n], on: DRUM
    end  #if row[n] > 0
    # sample :elec_flip, pan: [-1,1].choose if g[0][n] > 0
  end
end
# loop do
#   sl = m(K8, max:63).round
#   midi num_to_lp( rrand_i(0,64) ), sustain: m(K7) + 0.05, vel: tick%127, channel: 1, port: "launchpad_mini"
#   sleep 0.006 + m(K1)
# end

end # krush all
    end # echo all
  end # dist all
end # lpf all

end # channel select

@NOTIFICATION_ERRORS = 1
