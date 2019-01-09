in_thread do  # MIDI port reset
  if  __get_midi_ports.include? '<error>'
    puts "RESETTING MIDI"
    __midi_system_reset
  end
end

use_random_seed Time.now.usec

run_file '/scratch/midieval-weapons/sonicpi/sampler/keys.pi.rb'

run_file '/scratch/midieval-weapons/sonicpi/lib-touchosc.pi.rb'
use_osc '192.168.1.6', 9999

##| sams = load_samples ""
sams  = load_samples '~/Documents/audio/', /gtr-(?!.*slsess).*/
@sams = sams

drums = load_samples "/Users/textchimp/Documents/hydrogen/drumkits/**"

##| s = sams.choose

##| s = "/Users/textchimp/Downloads/watts1.wav"

@m = Hash.new 64 unless defined? @m

def m(key, rnge=1.0)
  return @m[:pc] if key == :pc
  return @m[:note] if key == :note
  @m[key]/127.0 * rnge
end

# s = sams[ m(:pc) ]

s = sams[ o('/1/rotary/1', 'sam', range:sams.length).to_i ]
s = sams[14]
@s = s
# set :sam, o('/1/rotary/1', 'sam', range:sams.length).to_i
cl "sam:", m(:pc)

def sammy(vel)
end

sl = 0

def play_sample(sam:, slices:, slice:, acc:, beats:)
  sample sam,
    slice: slice, #c(20, 30), #slice,
    num_slices: slices,
    attack: o(3, 'atk', 0.2), #range:zzz),
    release: o(4, 'rel'), #range:zzz),

    # rate: o(5, 'rate', range:2){|x| x - 1} - 1,

    rate: o(5, 'rate', map:[0.25, 0.5, 1.0]),

    lpf: o(7, 'lpf', range:130),
    on: spread(
      acc, # seq(6, 5, 1),
      beats
    ).look,
    pan: p # c(-1, 1, 1, -1) #p
end

with_fx :reverb do |rvb|
  with_fx :distortion do |dist|
    live_loop :sam do
      tick
      control dist, mix: o(9, 'dist')
      control rvb, mix: o(8, 'rvb')

      max_slices = 100
      slices = 1 + o(1, 'nslices', range:max_slices).to_i
      slice = o(2, 'slice', range:max_slices).to_i

      set :slices, slices
      # sl += o(2, 'sl inc', range: 2)
      # slice = sl
      # cl "slice: #{slices}, slices: #{slices}"
      p = rdist o(6, 'pan')

      beats = o('/1/rotary/3', 'spr b', range:16).to_i
      acc = o('/1/rotary/2', 'spr a', range:beats).to_i
      # cl acc, beats


      zzz = sample_duration(s) / slices.to_f

      s = o('/1/rotary/1', 'sam', map: sams)
      # s = @sams[ o('/1/rotary/1', 'sam', range:@sams.length).to_i ]

      # play_sample sam: s, slices: slices, slice: slice, acc: acc, beats: beats

      ##| puts (get(:ytouch).to_f / 127.0)
      # cl get(:point)
      sleep 0.01 + o(10, 'zzz', range: zzz) # + seq(0.1, 0.2)
    end
  end
end




live_loop :ryddm do
  sync :sam
  # sample drums[450], on: spread(seq(4,5),14).tick, lpf: 130
end

live_loop :midi do
  chan, val, other = sync '/midi/spd-1p/*/*/*_change'
  if chan < 12
    @m[:pc] = chan
    next
  end
  @m[chan] = val
  cl @m, chan, val, other
end

live_loop :midi_note do
  chan, val = sync "/midi/spd-1p/*/*/note_on"
  next if val == 0
  @drum_vels[ get(:index) ] = val

  sammy val

  @m[:note] = val
  # cl "NOTE", chan, val
end


# kbd :note_off do
#   cl "LAM OFF"
# end

kbd :cc do |k, _, v|
  cl 'cc', k
  label = case k
    when 7      then :m
    when 21..28 then "k#{k-20}"
    when 41..48 then "s#{k-40}"
    else "cc#{k}"
  end
  set( label, v / 127.0 )
end

kbd :on do |k, n, v|
  # cl "Lambda here! #{[k, n, v]}, #{get :slices}"
  # cl 'slices', slices
  sam = @sams[ (get(:m)*@sams.length).to_i ]
  in_thread do
    loops = (get(:s1) * 20).to_i
    wrap = (get(:s2) * 20).to_i
    cl loops, wrap
    loop do
      slices = 1 + get(:k8) * 100
      sample sam, num_slices: slices, slice: (slices*n).to_i, attack: 0.01
      sleep sample_duration(sam)/slices
      break unless key_held( k )
    end
  end
end
