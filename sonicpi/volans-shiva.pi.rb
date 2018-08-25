use_midi_defaults port: 'linuxsampler_in_0'
use_osc '192.168.1.2', 9999
set_sched_ahead_time! 0.1
use_bpm 42 # 45

def cls(*args)
  cl *args, file:'score.pi.log'
end

load '/scratch/midieval-weapons/sonicpi/score-parser.pi.rb'
clc "START______________________"

load '/scratch/midieval-weapons/sonicpi/volans-shiva-score.pi.rb'

piano1 = []
piano2 = []
SCORE.each_with_index do |el, i|
  # separate interleaved (alternating) arrays for two pianos into two separate arrays
  i.even? ? piano1 += el : piano2 += el
end

# inject version
# piano1, piano2 = score.each_with_index.inject([ [], [] ]) do |acc, (el, index)|
#   # separate interleaved (nested, alternating) arrays for two pianos into two separate arrays
#   index.even? ? acc[0] += el : acc[1] += el
#   acc
# end

@piano1 = score_parse( piano1,  debug_label:'Piano-1 (L)', debug_start:(defined?(start) ? start-1 : 0) )  unless PARTS == :r # LEFT
@piano2 = score_parse( piano2,  debug_label:'Piano-2 (R)', debug_start:(defined?(start) ? start-1 : 0) )  unless PARTS == :l # RIGHT

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

# Validation:
# only checks that bass & treble measures have same duration
# TODO: also check valid note values are entered?
validate_score( @piano1, label:'p1(L)' ) unless PARTS == :r # LEFT
validate_score( @piano2, label:'p2(R)' ) unless PARTS == :l # RIGHT

# asdasd

# File.write('/scratch/midieval-weapons/sonicpi/volans-piano2-score-snapshot-test.pi.rb', @piano2.inspect)
load '/scratch/midieval-weapons/sonicpi/volans-piano1-score-snapshot-test.pi.rb'
compare_score_against_snapshot( @piano1 )


# require 'pp'; cl "S", score.pretty_inspect
# cl 'j', JSON.pretty_generate(new_score[:l])
# raise 'done'
#

set(:fader1, 0)
set(:fader2, 0.6)
set(:fader3, 0)

chans  = [ 3, 1 ]

#RANDOM
comment do
  live_loop :rando do
    len = @piano1[:l].length
    bar = rand > 0.8  ?  bar : rrand_i(0, len-1)
    play_score_measure @piano1, bar, c:chans[0], pan:127  # LEFT spkr, facing desk
    play_score_measure @piano2, bar, c:chans[1], pan:1    # RIGHT spkr, facing desk
  end
end

# MAIN PLAY
uncomment do
  chans  = [ 3, 1 ]
  start  = START  ? START-1 : 0
  count  = COUNT  ? COUNT   : @piano1[:l].length
  set(:start, start)
  set(:count, count)
  repeat = REPEAT ? REPEAT  : false
  parts  = PARTS  ? PARTS   : :both
  metro  = METRO  ? METRO   : false
  metro_sample = :tabla_na

  cl "start: #{start}, count: #{count}, repeat: #{repeat}, parts: #{parts}, metro: #{metro}"

  f1_prev_l = (get(:fader1) * count).ceil
  f1_prev_r = (get(:fader1) * count).ceil

  unless parts == :r
    live_loop :shiva_l do
      use_bpm map_range(get(:fader2), 0, 1.0, 10, 60)

      f1 = (get(:fader1) * (count-start)).ceil
      cl "L raw: #{get(:fader1)}, f1: #{f1}, prev: #{f1_prev_l}"
      tick_set(:l, f1) if get(:fader1) != f1_prev_l
      f1_prev_l = get(:fader1)


      mes = repeat ?  start + (tick(:l) % count)  :  start + tick(:l)

      osc("/1/fader1/label", "bar #{ start + f1 + 1 } (#{mes+1})")
      osc("/1/fader3/label", "rep #{ (get(:fader3) * get(:count)).ceil }")

      sample metro_sample, pan: 1, on: metro   # play metronome marker
      play 100, release:0.1, pan: 1, amp: 2, on: (metro && repeat && mes == start)  # play repeat restart marker
      cl "measure: #{mes+1}".green, file: 'score.pi.log'
      play_score_measure @piano1, mes, c:chans[0], pan:127  # LEFT spkr, facing desk
      stop if !repeat && mes >= count
    end
  end
  unless parts == :l
    live_loop :shiva_r do
      chek = map_range(get(:fader2), 0, 1, 10, 60)
      cl "BPM: #{get(:fader2)}"
      use_bpm chek
      cl "FADER2: #{ get(:fader2) }"
      osc("/1/fader2/label", "bpm #{current_bpm.to_i}")

      f1 = (get(:fader1) * (count-start)).ceil
      cl "R raw: #{get(:fader1)}, f1: #{f1}, prev: #{f1_prev_r}"
      tick_set(:r, f1) if get(:fader1) != f1_prev_r
      f1_prev_r = get(:fader1)

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

live_loop :osc do
  path, val = sync "/osc/**", path:true
  if path.match(%r{ /osc/ (\d+) /fader(\d+) }x)
    cl [path, val].inspect, file:'score.pi.log'
    # cl $1, $2, file:'score.pi.log'
    set "fader#{$2}", val
    cl "SET: fader#{$2}", file:'score.pi.log'
  #   osc "/#{$1}/fader#{$2}/label", "bar #{get(:start) + (val *   get(:count)).floor.to_i}"
  end
end
