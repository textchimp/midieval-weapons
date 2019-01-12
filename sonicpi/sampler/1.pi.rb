reset_midi
true_random

run_file '/scratch/midieval-weapons/sonicpi/lib-launchpad-buttons.pi.rb'

run_file '/scratch/midieval-weapons/sonicpi/sampler/keys.pi.rb'

run_file '/scratch/midieval-weapons/sonicpi/lib-touchosc.pi.rb'
use_osc '192.168.1.6', 9999

##| sams = load_samples ""
sams  = load_samples '/Users/textchimp/Documents/audio/', /gtr-(?!.*slsess).*/
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

def play_sample(sam, slices:, slice:, acc:, beats:)
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

      play_sample s, slices: slices, slice: slice, acc: acc, beats: beats

      ##| puts (get(:ytouch).to_f / 127.0)
      # cl get(:point)
      sleep 0.01 + o(10, 'zzz', range: zzz) # + seq(0.1, 0.2)
    end
  end
end



# live_loop :ryddm do
#   sync :sam
#   sample drums[450], on: spread(seq(4,5),14).tick, lpf: 130
# end


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
  @drum_vels[ g(:index) ] = val

  sammy val

  @m[:note] = val
  # cl "NOTE", chan, val
end


# kbd :note_off do
#   cl "LAM OFF"
# end

# kbd :cc do |k, _, v|
#   cl 'cc', k
#   label = case k
#     when 7      then :m
#     when 21..28 then "k#{k-20}"
#     when 41..48 then "s#{k-40}"
#     else "cc#{k}"
#   end
#   set( label, v / 127.0 )
# end

kbd :cc do |k, n, v|
  # next unless k == 64
  # if v > 0
  #   midi 105,
  # end
  case k
  when 64
    cl "hold".send(v > 0 ? :green : :red)
  when  7
    # master slider
    s = @sams[ (get(:master, 0.5)*@sams.length).to_i ]
    cl g(:m), s.path.sub('/Users/textchimp/Documents/audio/', '')
  end
end

kbd :note_on do |k, n, v|
  # cl 'slices', slices
  sam = @sams[ (get(:master, 0.5)*@sams.length).to_i ]

  sam = '/Users/textchimp/Downloads/watts1.wav'

  # cl g(:m), sam.path.sub('/Users/textchimp/Documents/audio/', '')

  # new syntax for tilde: 'proportional to' or mapped to array from 0..1
  #sam = @sams ~ g(:m)  ~= ?? ~~??

  with_fx :reverb do |rvb|
    with_fx :distortion do |dist|
      with_fx :flanger do |fla|
        with_fx :lpf, slide: 0.1 do |lpf|

    in_thread do
      loops = (g(:s1) * 20).to_i
      wrap = (g(:s2) * 20).to_i

      # set :rate, g(:k7, 1)  # to remember across iterations

      # cl "pb", get(:pb, 0.5), get(:pb, 0.5)*2 - 1
      # use (remember) same initial pan for all iterations
      pan = get(:pb, 0.5) * 2 - 1

      loop do

        control dist, mix: get(:s1, 0)
        control rvb, mix: get(:s2, 0)
        control fla, mix: get(:s3, 0)
        control lpf, cutoff: 10 + (1- get(:s4, 0)) * 130

        slices = 1 + get(:k8, 0) * 100
        sample sam,
          amp: v * 2,
          num_slices: slices,
          slice: (slices*n).to_i,
          # onset: (slices*n).to_i,
          attack: 0.01,
          # norm: 1,
          # decay:0.9,
          pan: pan,
          rate: get(:k7,1) #get(:rate)

        len = sample_duration(sam)/slices
        sleep len + g(:k6, 0) * len*2

        break unless g(:ped) > 0 || key_held( k )
      end
    end

  end #sfx
  end
  end
  end

end

osc_handler '/1/push/1' do |p, v|
  cl "HANDLED! ", p, v
  __stop_other_jobs
end

osc_handler '/1/push/' do |p, v, rest|
  cl "HANDLED! ", p, v, rest
end

osc_handler '/1/toggle/11' do |p, v|
  cl "go!".green
  __rerun_last_osc_code
end
