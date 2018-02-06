def g(path, default, arr=false)
  got = get[path]
  if got && got.any?
    arr ? got : got[0]
  else
    default
  end
end

##| fingers = []

def track_finger(n)

  lastx = 0.0
  lasty = 0.0
  lastz = 0.0

  live_loop :leap do
    x,y,z = g "/osc/leap/0/#{n}/norm/fpos", [0.0,0.0,0.0], true
    vx, vy, vz = (lastx - x), (lasty - y), (lastz - z)
    puts y
    if vy > 0.2
      play 40 + ((1-y) * 20).to_i
      sleep 0.1
    end

    sleep 0.1
    lastx,lasty,lastz = x,y,z
  end
end

track_finger 0
track_finger 1
track_finger 2


comment do
  live_loop :l do
    g = g( "/osc/leap/0/pinch", 0)
    ind = (g * 16)
    puts ind
    play scale(:c3, :chinese, num_octaves: 4)[ind.to_i], attack: 0.1
    sleep 0.2
  end
end
