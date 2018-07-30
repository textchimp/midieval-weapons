use_midi_defaults port: 'linuxsampler_in_0'
set_sched_ahead_time! 0.1

load '/scratch/midieval-weapons/sonicpi/score-parser.pi.rb'

clc "START______________________"

use_bpm 45

# opting for interleaved arrays for L-R pianos because it's a relatively uncommon case

score =
%w(
1: f  [ e4-e_ f4-e f4-e_ b4-e e5-s r-s ]2q5
 : f  [ b3-e  b3-e b3-e_ d4-e f4-s r-s ]2q5
),
%w(
1: f  [ d4-e  d4-e d4-e_ f4-e b4-s r-s ]2q5
 : f  [ a3-e  a3-e a3-e_ c4-e e4-s r-s ]2q5
),
%w(
2: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-f          a3,d4-s-a r-s r-e
),
%w(
2: d5-w-p             r-q
 : r-w                r-q
),
%w(
3: b5,cs6-w-p         r-q
 : r-w                r-q
),
%w(
3: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-p          a3,d4-s-f r-s r-e
), #1/L:
%w(
4: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-f          a3,d4-s-a r-s r-e
), #2/R:
%w(
4: p  [ d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a d4-e c5,e5-e-a ]4q5 r-q
 : p  [ a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a a3-e b2,d3-e-a ]4q5 r-q
),
%w(
5: e6,b6-w-pp      r-q
 : a4,gs5-w-p         r-q
),
%w(
5: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-f          a3,d4-s-a r-s r-e
),
%w(
6: [ f  f4-e_ e4-s r-s b4-e  b4-s r-s e5-s r-s   ff  e5-e_ b5-s r-s e4-e_ f4-s r-s f4-e ]4q5
 : [ f  b3-e  b3-s r-s b3-e_ d4-s r-s f4-s r-s   ff  d4-e_ a4-s r-s b3-e  b3-s r-s b3-e ]4q5
),
%w(
6: [ f  d4-e d4-s r-s d4-e_  f4-s r-s b4-s r-s   ff a4-e_    e5-s r-s d4-e  d4-s r-s d4-e ]4q5
 : [ f  a3-e a3-s r-s a3-e_  c4-s r-s e4-s r-s   ff cs4-e_ d4-s r-s a3-e_ a3-s r-s a3-e ]4q5
),
%w(
7: a4,e5-w-f          a4,e5-s-a r-s r-e
 : a3,d4-w-p          a3,d4-s-f r-s r-e),
%w(
7: b5,cs6-w-p         r-q
 : r-w r-q
),
%w(
8: e6-w-p            a4,e5-s-f r-s r-e
 : r-w                r-q
),
%w(
8: a4,e5-w-f          r-q
 : a3,d4-w-f          a3,d4-s-a r-s r-e
)


template = '
%w(
:
 :
),
%w(
:
 :
)
'


START = 1
COUNT = nil
REPEAT = nil
# use_bpm 50

piano1 = []
piano2 = []
score.each_with_index do |el, i|
  # separate interleaved (nested, alternating) arrays for two pianos into two separate arrays
  i.even? ? piano1 += el : piano2 += el
end

# inject version
# piano1, piano2 = score.each_with_index.inject([ [], [] ]) do |acc, (el, index)|
#   # separate interleaved (nested, alternating) arrays for two pianos into two separate arrays
#   index.even? ? acc[0] += el : acc[1] += el
#   acc
# end

@piano1 = score_parse(piano1)  # LEFT
@piano2 = score_parse(piano2)



comment do
  # play 60
  score = %w(
  1: a c4-q_  c5-q
   : r-q r-s e6-w
  )

  START = 7
  COUNT = nil
  PAN = 1
  REPEAT = false

  testscore = score_parse( score )

  pan = (PAN || 64)
  start = (START || 1) - 1
  repeat = REPEAT || false
  # count = (COUNT || 1_000_000)
  count = 1 #(COUNT || 1)

  live_loop :shiva_l do
    if repeat
      mes = start + (tick(:l) % count)
    else
      mes = start + tick(:l)
    end
    play_score_measure @piano1, mes , c:3, pan:pan  # LEFT spkr, facing desk
  end
  # play_score_measure testscore, 0, c:3
  # play 60
  # stop
end



# require 'pp'; cl "S", score.pretty_inspect
# cl 'j', JSON.pretty_generate(new_score[:l])
# raise 'done'
#

uncomment do
  chan = 3
  start = (START || 1) - 1
  count =  (COUNT || @piano1[:l].length)
  repeat = (REPEAT || false)
  live_loop :shiva_l do
    mes = repeat ?  start + (tick(:l) % count)  :  start + tick(:l)
    play_score_measure @piano1, mes, c:chan, pan:127  # LEFT spkr, facing desk
    cl "measure: #{mes}".green, file: 'score.pi.log'
    stop if !repeat && mes >= count
  end
  live_loop :shiva_r do
    mes = repeat ?  start + (tick(:r) % count)  :  start + tick(:r)
    play_score_measure @piano2, mes, c:chan, pan:1
    stop if !repeat && mes >= count
  end
end

comment do
    play_score_measure @piano1, 2, c:3, pan:127
end
