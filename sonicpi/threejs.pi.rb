# TODO: syntax errors such as leaving comma out of args list
# does NOT cause notification popup


use_osc 'localhost', 57121

Z = 0.25

def divs(n, *nums)
  return (n % nums.first == 0) if nums.length == 1
  nums.any? { |x| n % x == 0 }
end

def r(n)
  [:rest] * n
end

with_fx :sound_out_stereo, output: 1, amp: 0 do

key = :c2

live_loop :go do


  sc = scale(key, :minor_pentatonic) + r(30)
  synth :pulse,
    note: sc.choose,
    attack: 2,
    release: 4,
    amp: 0.2,
    pan: rrand(-1, 1),
    pulse_width: 0.3,
    cutoff: 70

  if tick(:counter) % 24 == 0

    # in_thread do
    #   density 2 do
    #     sample :tabla_na
    #     sleep Z
    #   end
    # end

    key  = [:c2, :e2, :b3, :c4].ring.tick(:keys)
  end

  if spread(2, 13).tick
    sample :bd_klub
    osc '/klub', look
  end
  if divs(look, 5)  #|| spread(3, 7).look
    sample :tabla_te_m #:bd_boom
    osc '/boom', look
  end

  sleep Z
end


end #routing
