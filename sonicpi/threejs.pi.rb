
use_osc 'localhost', 57121

def divs(n, *nums)
  return (n % nums.first == 0) if nums.length == 1
  nums.all? { |x| n % x == 0 }
end

def r(n)
  [:rest] * n
end

with_fx :sound_out_stereo, output: 1, amp: 0 do

live_loop :go do
  # use_synth :tr
  sc = scale(:e3, :egyptian) + r(20)
  play sc.choose, attack: 0.1, finish: 0.001, amp: 0.5
  if spread(2, 9).tick
    sample :bd_klub
    osc '/klub', look
  end
  if divs(look, 4)  #|| spread(3, 7).look
    sample :tabla_te_m #:bd_boom
    osc '/boom', look
  end

  sleep 0.25
end


end #routing
