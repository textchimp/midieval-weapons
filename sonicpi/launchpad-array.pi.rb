run_file '/scratch/midieval-weapons/sonicpi/lib-launchpad-buttons.pi.rb'
sleep 1

sc = scale(:c2, :minor, num_octaves: 7)

live_loop :mel do

  @buttons.each_with_index do |val, ind|
    if val
      play sc[ind]  #40 + ind
      # midi sc[ind], sustain: 1.0, vel: 100, port: 'linuxsampler_in_0'
      sleep 0.2
    end
  end

  sleep 0.2
end
