use_midi_defaults port: 'linuxsampler_in_0'
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
@vel = Hash.new(100)
@vel['pp']  = 50
@vel['p']   = 75
@vel['mp']  = 80
@vel['mid'] = 90
@vel['mf']  = 100
@vel['f']   = 110
@vel['ff']  = 120


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

def score_parse(s, label=nil)
  # process each chord-or-note
  @score[label] = {}
  measure = 0
  s.inject([]) do |acc,chord|
    if chord =~ /(\d+)\:/
      measure = $1
      @score[label][measure] = []
      next acc  # skip bar numbers at start of lines (use to define measures)
    end
    notes, dur, vel = chord.split('-')
    dur = dur.to_f > 0 ? dur.to_f : @dur[ dur ] # use literal number, otherwise lookup symbol
    vel = vel.to_f > 0 ? vel.to_f : @vel[ vel ]
    n = split_notes(notes, dur, vel)
    @score[label][measure] << n
    acc << n
  end
end

def split_notes(notes, dur, vel)
  # split a chord string like 'a4,c5' into an array of notes with the same duration and velocity
  notes.split(',').inject([]) do |ac, note|
    ac << [
      note.to_f > 0 ? note.to_f : note.to_sym,
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
def play_measure(label, m, opts = {})
  measure = @score[label][m.to_s]
  measure.each { |mes| play_score_note(mes, **opts) }
end

score_left = %w[
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
]

score_right = %W[
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
