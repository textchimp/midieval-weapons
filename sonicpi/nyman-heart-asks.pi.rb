use_midi_defaults port: 'linuxsampler_in_0'
# use_osc '192.168.1.2', 9999
set_sched_ahead_time! 0.1
use_bpm 15 # 45
run_file '/scratch/midieval-weapons/sonicpi/score-parser.pi.rb'
clc "START______________________"

# score = %w{
# 1: p  (a3,e3,f3,b4-w    a3-w) b4-e
#  :    (a3-w a3-w)           p a3-s. b3-t
# 2:    b4,a5-h      d3-q.  r-e
#  :    b2-h         mp a3-q f3-q
# 3: mp a2-w.. gs3-q
#  :    a3-q_ c3-q_ e3-q_ b3-q    p c5-w
# 4:    b3,a3-q  a2-w-p
#  :    (b3-h       b3-h) b3-q
# 5:    r-h      a2-e r-e c2-q
#  :    r-h.        c3-e_ a2-e
# }
#
# score = %w{
# 1: c3-h eb3-q g3-h b3-q   mf a2,a3-h. :
# 2: a2-w.  b4-e r-q pp cs3-e  p b3-q  :
# }

score =
%w{
 1:  p  ped  e5-s-a e4-s a4-s e5-s-a e4-s a4-s  ped  e5-s-a e4-s a4-s d5-s-a e4-s a4-s  ped  c5-s-a e4-s a4-s c5-s-a e4-s a4-s  ped  e5-s-a e4-s a4-s c5-s-a e4-s a4-s
  :  pp ped  c4-s   a3-s e3-s-a a3-s c4-s a3-s  ped  b3-s   g3-s d3-s-a g3-s b4-s g3-s  ped  a3-s   e3-s c3-s-a e3-s a3-s e3-s  ped  a3-s   e3-s c3-s-a e3-s a3-s e3-s
 2:     ped  e5-s-a e4-s a4-s e5-s-a e4-s a4-s  ped  e5-s-a e4-s a4-s d5-s-a e4-s a4-s  ped  c5-s-a e4-s a4-s c5-s-a e4-s a4-s  ped  a4-s-a d4-s fs4-s a4-s-a d4-s fs4-s
  :  pp ped  c4-s   a3-s e3-s-a a3-s c4-s a3-s  ped  b3-s   g3-s d3-s-a g3-s b4-s g3-s  ped  a3-s   e3-s c3-s-a e3-s a3-s e3-s  ped  a3-s   d3-s fs3-s-a a3-s d3-s fs3-s
}

@piano = score_parse(score)
# validate_score(@piano)
cl(@piano.inspect)

pedals = { l: nil, r: nil }  # seem to need to pass this thru, no globals
live_loop :heart_asks_pleasure_first do
  play_score_measure @piano, tick % @piano[:l].length, c:1, pan_hands: 0.9, pedal_notes: pedals
end
