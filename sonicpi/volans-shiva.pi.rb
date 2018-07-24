use_midi_defaults port: 'linuxsampler_in_0'
set_sched_ahead_time! 1
use_bpm 45

# durations lookup
@dur = Hash.new(0.25)
@dur['t'] = 0.03125
@dur['s'] = 0.0625
@dur['e'] = 0.125
@dur['q'] = 0.25
@dur['q/5'] = @dur['q']/5.0
@dur['h'] = 0.5
@dur['h/5'] = @dur['h']/5.0
@dur['w'] = 1
@dur['w2/5'] = 2*@dur['q']/5.0
@dur['w1/5'] = @dur['q']/5.0

# velocity lookup
@vel = Hash.new(90)
@vel['pp']  = 50; @vel['p']   = 75
@vel['P']   = 50
@vel['mp']  = 80
@vel['a']   = 96
@vel['mf']  = 100
@vel['f']   = 110
@vel['ff']  = 120; @vel['F']   = 120
@vel['acc'] = 6

def mplay(args  = {})  # **args
  # optional shorter keys
  args[:pan]      ||= args[:p]
  args[:channel]  ||= args[:c]
  args[:note]     ||= args[:n]
  args[:velocity] ||= args[:v]
  args[:sustain]  ||= args[:s]

  midi args[:note], **args
end

# hash of notes, indexed by measure number
@score = {}

def check_set_score_hash_measure(score_hash, chord)
  return false unless chord =~ /(\d+)\:/
  measure = $1
  score_hash[measure] = []
  measure
end

def score_parse(s, key=nil)
  # process each chord-or-note

  @score[key] = {}   # score hash for the given key
  measure = 0
  timing_group = nil

  s.inject([]) do |acc,chord|

    # check for N: measure numbers
    if m = check_set_score_hash_measure(@score[key], chord)
      measure = m
      next acc
    end

    # check for '[ / ]N' timing change brackets
    case chord
    when '['
      timing_group = []
      next acc
    when /\](\d+)/
      beats = ($1).to_f
      cl "FOUND END #{beats}"
      cl timing_group.inspect
      notes = timing_group.map do |notes|
        notes.map do |note, dur, vel|
          cl "note: '#{note.inspect}', dur: '#{dur.inspect}', vel: '#{vel.inspect}', beats: '#{beats.inspect}'"
          cl "OUT", [note, dur/beats, vel].inspect
          [note, dur/beats, vel]
        end
      end
      cl "notes:", notes.inspect
      timing_group = false
      acc += notes
      cl "t-acc", acc.inspect
      next acc
    end

    notes, dur, vel = chord.split('-')
    dur = dur.to_f > 0 ? dur.to_f : @dur[ dur ] # use literal number, otherwise lookup symbol
    vel = vel.to_f > 0 ? vel.to_f : @vel[ vel ]

    if timing_group
      timing_group << split_notes(notes, dur, vel)   # TODO: do we actually want += and not <<  ???????
      acc
    else
      n = split_notes(notes, dur, vel)
      @score[key][measure] << n
      acc << n
      cl "acc", acc.inspect
      acc
    end

  end # inject
end

def split_notes(notes, dur, vel)
  # split a chord string like 'a4,c5' into an array of notes with the same duration and velocity
  notes.split(',').inject([]) do |ac, note|
    ac << [
      note.to_f > 0 ? note.to_f : note.to_sym,  # use literal MIDI note number or SPi symbol
      dur,
      vel
    ]
  end
end

# play a single chord or note from the score array
def play_score_note(notes, opts = {})
  opts[:vscale] ||= 1.0
  notes.each do |n|
    mplay note:n[0], sustain:n[1], velocity:n[2] * opts[:vscale], **opts
  end
  sleep notes[0][1]  # just use the first note's sleep value (TODO: better)
end

# play a single measure by number
def play_measure(key, m, opts = {})
  measure = @score[key][m.to_s]
  measure.each { |mes| play_score_note(mes, **opts) }
end

# L1: [ e4-e_ f4-e f4-e_ b4-e e5-s r-s ]5
# [ b3-e  b3-e b3-e_ d4-e f4-s r-s ]5 ),
# R1: [ e4-e_ f4-e f4-e_ b4-e e5-s r-s ]5
# [ b3-e  b3-e b3-e_ d4-e f4-s r-s ]5 ),

score_left =
%w(
  [ e4-e_ f4-e f4-e_ b4-e e5-s r-s ]5
  [ b3-e  b3-e b3-e_ d4-e f4-s r-s ]5


2: a4,e5-w-f          a4,e5-s-a r-s
   a3,d4-w-f          a3,d4-s-a r-s

3: b5,cs6-w-p         r-q
   r-w                r-q  (r-wq??)

4: a4,e5-w-f          a4,e5-s r-s
   a3,d4-w            a3,d4-s r-s
)

# 0:  [ e4,f4-e f4-e f4-e b4-e e5-s r-s ]5
score_left = %w(
1:  b3,e4-w2/5 b3,f4-w2/5 b3,f4-w2/5 d4,b4-w2/5 f4,e5-w1/5 r-w1/5
2:  a3,d4,a4,e5-w-f  a3,d4,a4,e5-s-mf  r-s r-e
3:  b5,cs6-w-p  r-q
4:  a3,d4,a4,e5-w-f  a3,d4,a4,e5-s-mf  r-s r-e
5:  a4,gs5,e6,b6-w-p  r-q
6:  b3,f4-h/5 b3,e4-q/5 r-q/5  b3,b4-h/5 d4,b4-q/5 r-q/5 f4,e5-q/5 r-q/5  d4,e5-h/5 a4,b5-q/5 r-q/5 b3,e4-h/5 b3,f4-q/5  r-q/5 b3,f4-h/5
7:  a3,d4,a4,e5-w    a3,d4,a4,e5-s-f  r-s r-e
8:  e6-w-p                 a4,e5-s-f  r-s r-e
9:  a3,d4-w-p              a4,e5-s-mf r-s r-e
10: a3,d4-w-p        a3,d4,a4,e5-s-f  r-s r-e
11: a3,d4,a4,b5-w-p  a3,d4,a4,e5-s-mf r-s r-e
12: r-w r-q
)

# 0:  r-w r-w
score_right = %w[
1:  a3,d4-w2/5 a3,d4-w2/5 a3,d4-w2/5 c4,f4-w2/5 e4,b4-w1/5 r-w1/5
2:  d5-w-p r-q
3:  a3,d4,a4,e5-w-f   a3,d4,a4,e5-s    r-s r-e
4:  a3,d4-h/5-p b2,d3,c5,e5-h/5-mf  a3,d4-h/5 b2,d3,c5,e5-h/5-mf  a3,d4-h/5 b2,d3,c5,e5-h/5-mf  a3,d4-h/5 b2,d3,c5,e5-h/5-mf  a3,d4-h/5 b2,d3,c5,e5-h/5-mf  r-q
5:  a3,d4,a4,e5-w-f   a3,d4,a4,e5-s    r-s r-e
6:  a3,d4-h/5 a3,d4-q/5 r-q/5  a3,d4-h/5 c4,f4-q/5 r-q/5 e4,b4-q/5 r-q/5  cs4,a4-h/5 d4,e5-q/5 r-q/5 a3,d4-h/5 a3,d4-q/5 r-q/5 a3,d4-q/5
7:  b5,cs6-w-p    r-q
8:  a3,d4,a4,e5-w-f   a3,d4-s          r-s r-e
9:        a4,e5-w-p   a3,d4-s-mf       r-s r-e
10:       a4,e5-w-p   a3,d4,a4,e5-s-mf r-s r-e
11: gs5,e6-w-p    r-q
12: a3,d4,a4,e5-w-f  a3,d4,a4,e5-s-mf  r-s r-e
]

# process score arrays for both pianos
score_left  = score_parse(score_left,  :l)  # add .ring here to loop
score_right = score_parse(score_right, :r)

# left piano
live_loop :shiva_l do
  play_score_note score_left.tick(:l),  c:3, pan:127 #, vscale:0.5
end

# right piano
live_loop :shiva_r do
  play_score_note score_right.tick(:r), c:3, pan:1
end

# to play one measure:
#
# m = 2
# live_loop :gol do
#   play_measure :l, m, c:3
# end
#
# live_loop :gor do
#   play_measure :r, m, c:3
# end