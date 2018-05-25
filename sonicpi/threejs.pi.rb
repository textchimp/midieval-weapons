# TODO: syntax errors such as leaving comma out of args list
# does NOT cause notification popup

OUT = 3

use_osc 'localhost', 57121

Z = 0.25

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

key = :c2

live_loop :go do

with_fx :distortion do |dst|
  control dst, distort: 0
  with_fx :slicer do |slicer|
    control slicer, pulse_width: 0.7, probability: 0.99, smooth: 0.3

    sc = scale(key, :minor_pentatonic) + r(30)
    synth :pulse,
      note: sc.choose,
      attack: 0.3, #2
      release: 4,
      amp: 0.4,
      pan: rrand(-1, 1),
      pulse_width: 0.9,
      cutoff: 58
    end
  end

  if tick(:counter) % 24 == 0

    # in_thread do
    #   density 2 do
    #     sample :tabla_na
    #     sleep Z
    #   end
    # end

    key  = [:c2, :e2, :b3, :c4].ring.tick(:keys)
  end

  if spread(4, 15).tick   # 4/9 is good
    sample :bd_klub
    osc '/klub', look
  end
  if divs(look,  5, 12)  #|| spread(3, 7).look
    sample :tabla_te_m #:bd_boom
    osc '/boom', look
  end
  if spread(4, 7).look
    sample drums[ 11 * 16 + 12   ] #, rate: 1, finish: 0.02
  end
  sleep Z
end


end #routing

# send values to dat.gui!!!!!!!!!!!!!!!
