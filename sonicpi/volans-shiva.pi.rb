use_midi_defaults port: 'linuxsampler_in_0'
set_sched_ahead_time! 0.1
use_bpm 45

run_file '/scratch/midieval-weapons/sonicpi/score-parser.pi.rb'
clc "START______________________"

load '/scratch/midieval-weapons/sonicpi/volans-shiva-score.pi.rb'

piano1 = []
piano2 = []
SCORE.each_with_index do |el, i|
  # separate interleaved (nested, alternating) arrays for two pianos into two separate arrays
  i.even? ? piano1 += el : piano2 += el
end

# inject version
# piano1, piano2 = score.each_with_index.inject([ [], [] ]) do |acc, (el, index)|
#   # separate interleaved (nested, alternating) arrays for two pianos into two separate arrays
#   index.even? ? acc[0] += el : acc[1] += el
#   acc
# end

@piano1 = score_parse( piano1, debug_start:(defined?(start) ? start-1 : 0) )  unless PARTS == :r # LEFT
@piano2 = score_parse( piano2, debug_start:(defined?(start) ? start-1 : 0) )  unless PARTS == :l # RIGHT

# cl "_______", @piano2.inspect, file: 'score.pi.log'

# testing
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
  chans  = [ 3, 1 ]
  start  = START  ? START-1 : 0
  count  = COUNT  ? COUNT   : @piano1[:l].length
  repeat = REPEAT ? REPEAT  : false
  parts  = PARTS  ? PARTS   : :both
  metro  = METRO  ? METRO   : false
  metro_sample = :tabla_na

  cl "start: #{start}, count: #{count}, repeat: #{repeat}, parts: #{parts}, metro: #{metro}"

  unless parts == :r
    live_loop :shiva_l do
      mes = repeat ?  start + (tick(:l) % count)  :  start + tick(:l)
      sample metro_sample, pan: 1, on: metro   # play metronome marker
      play 100, release:0.1, pan: 1, amp: 2, on: (metro && repeat && mes == start)  # play repeat restart marker
      cl "measure: #{mes+1}".green, file: 'score.pi.log'
      play_score_measure @piano1, mes, c:chans[0], pan:127  # LEFT spkr, facing desk
      stop if !repeat && mes >= count
    end
  end
  unless parts == :l
    live_loop :shiva_r do
      mes = repeat ?  start + (tick(:r) % count)  :  start + tick(:r)
      sample metro_sample, pan: -1, on: metro   # play metronome marker
      play 100, release:0.1, pan: -1, amp: 2, on: (metro && repeat && mes == start)  # play repeat restart marker
      play_score_measure @piano2, mes, c:chans[1], pan:1
      stop if !repeat && mes >= count
    end
  end

end #comment

comment do
    play_score_measure @piano1, 2, c:3, pan:127
end
