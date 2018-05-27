# TODO: syntax errors such as leaving comma out of args list
# does NOT cause notification popup
# TODO: redefine '|' to be random choice operator

use_osc 'localhost', 57121  # Node-websocket bridge

OUT = 1
Z = 0.25
@sprob = 1.0
@width = 0.4
@sphase = 0.25
@bpm = 60
@drums_vol = 1.0
@drums_rvb = 0
@synth_vol = 1.0
@synth_rvb = 1.0


key = :c2

drums = load_samples "/Users/textchimp/Documents/hydrogen/drumkits/BigMono/"
# 128:rimshot, 172: lite hihat 164-179, 196-211: long hihit
hihat = drums[172]

def divs(n, *nums)
  return (n % nums.first == 0) if nums.length == 1
  nums.any? { |x| n % x == 0 }
end

def r(n)
  [:rest] * n
end

with_fx :sound_out_stereo, output: OUT, amp: 0 do


live_loop :metro do
  use_bpm @bpm
  cue :beat, tick
  sleep Z
end

with_fx :reverb do |rvb|
with_fx :distortion do |dst|
with_fx :slicer do |slicer|
with_fx :level do |amp|

live_loop :synth do

  t, *_ = sync :beat
  control amp, amp: @synth_vol
  control dst, distort: 0
  control rvb, mix: @synth_rvb
  control slicer, pulse_width: @width, probability: @sprob, smooth: 0.3, phase: @sphase

  if tick(:counter) % 24 == 0
    # switch keys every 24 beats
    key  = [:c2, :e2, :f3, :c4].ring.tick(:keys)
  end

  sc = scale(key, :minor_pentatonic) + r(30)
  notey = sc.choose

  osc '/log', notey, rt(Z), key

  synth :pulse,
    note: notey,
    attack: 0.3, #2
    release: 4,
    amp: 0.4,
    pan: rrand(-1, 1),
    pulse_width: 0.9,
    cutoff: 100

  end # :synth
end #level
end #slicer
end #dist
end #reverb

with_fx :reverb do |rvb|
with_fx :distortion do |dst|
with_fx :level do |amp|

live_loop :drums do

  t, *_ = sync :beat
  control amp, amp: @drums_vol
  control dst, distort: 0
  control rvb, mix: @drums_rvb

  if spread(6, 15).tick   # 4/9 is good
    sample :bd_klub, amp: 2
    osc '/klub', look
    # if true
    #   in_thread do
    #     sample :bd_klub
    #     sleep Z/2.0
    #   end
    # end
  end

  # with_fx :reverb do
    if divs(look,  5, 12)  #|| spread(3, 7).look
      # sample :tabla_te_m #:bd_boom
      sample drums[ [131,127].ring.tick(:rim) ], amp:2
      osc '/boom', look
    end
  # end

  if spread(4, 7).look
    sample drums[ 11 * 16 + 12   ] #, rate: 1, finish: 0.02
  end

end #:drums

end #level
end #dist
end #reverb

end # audio output routing

live_loop :osc do
  type, val = sync "/osc/controls"
  # @c[type.to_s] = val
  case type
    when 'synthvol' then @synth_vol = val
    when 'synthrvb' then @synth_rvb = val
    when 'drumsvol' then @drums_vol = val
    when 'drumsrvb' then @drums_rvb = val
    when 'bpm'      then @bpm = val
    when 'scale'    then @width = val
    when 'sprob'    then @sprob = val
    when 'sphase'   then @sphase = val
    when 'play' then
      if val
        play 60
      end
  end
end
