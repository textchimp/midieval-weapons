reset_midi
true_random

run_file '/scratch/midieval-weapons/sonicpi/lib-launchpad-buttons.pi.rb'

run_file '/scratch/midieval-weapons/sonicpi/sampler/keys.pi.rb'

run_file '/scratch/midieval-weapons/sonicpi/lib-touchosc.pi.rb'
def set_osc_defaults
  use_osc '192.168.1.5', 9999
end
set_osc_defaults

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

# s = o('/1/rotary/1', 'sam', map:sams)
s = sams[14]
@s = s
# set :sam, o('/1/rotary/1', 'sam', sams.length).to_i
# cl "sam:", m(:pc)

def sammy(vel)
end

sl = 0

def play_sample(sam, slices:, slice:, acc:, beats:, pan:)
  sample sam,
    slice: slice, #c(20, 30), #slice,
    num_slices: slices,
    attack: o(3, 'attack', 0.2), #zzz),
    release: o(4, 'release'), #zzz),
    rate: o(5, 'rate', map:[0.25, 0.5, 1.0], first:1.0),
    lpf: o(7, 'lpf', 130, 10, int:true),
    on: spread( acc, beats ).look,
    amp: o('/1/rotary/1', 'amp', 2, first:2),
    pan: pan # c(-1, 1, 1, -1) #p
    # cl "p", p
end

with_fx :reverb do |rvb|
with_fx :distortion do |dist|
with_fx :krush do |krush|
with_fx :bpf, mix: 1.0, res:0.8 do |bpf|

  live_loop :sam do
    tick
    control rvb, mix: o(8, 'reverb')
    control krush, mix: o(14, 'krush')
    control dist,
      mix:     o(9, 'dist',first:0.5),
      distort: o(19, 'dist %', 0.99, first: 0.6)
    control bpf,
      res:    o(13, 'bpf resonance', 0.99),
      centre: o(12, 'bpf center', 20, 100),
      mix:    o('/1/rotary/12', 'mix'),
      amp:    o('/1/rotary/13', 'amp', 4, first:0.25)

    max_slices = 100
    slices = o(1, 'num slices', 1, max_slices, first:0.5, int:true)
    slice = o(2, 'slice', max_slices, first:0.5, int:true)

    set :slices, slices
    # sl += o(2, 'sl inc', 2)
    # slice = sl
    # cl "slice: #{slices}, slices: #{slices}"
    p = rdist o(6, 'pan')

    beats = o('/1/rotary/3', 'spr b', 16).to_i
    acc = o('/1/rotary/2', 'spr a', beats).to_i
    # cl acc, beats

    # s = o('/1/rotary/1', 'sam', map: sams)
    s = '/Users/textchimp/Downloads/watts1.wav'
    s = o(11, 'sample', map:@sams){ |s| s.path.sub('/Users/textchimp/Documents/audio/', '') }
    # cl "sample",  s.path.sub('/Users/textchimp/Documents/audio/', '')

    # s = @sams[ o('/1/rotary/1', 'sam', @sams.length).to_i ]

    if o('/1/toggle/12', 'loop', first:1) > 0 || false
      play_sample s, slices: slices, slice: slice, acc: acc, beats: beats, pan: p
    end

    zzz = sample_duration(s) / slices.to_f
    sleep 0.01 + 1.5 * o(10, 'sleep', zzz, first:0.5) # + seq(0.1, 0.2)

  end
end # fx
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


  set_osc_defaults

  # sam = '/Users/textchimp/Downloads/watts1.wav'

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
    cl loops, wrap
    # set :rate, g(:k7, 1)  # to remember across iterations
    # cl "pb", get(:pb, 0.5), get(:pb, 0.5)*2 - 1

    # use (remember) same initial pan for all iterations
    pan = get(:pb, 0.5) * 2 - 1

    loop do

      control dist, mix: get(:s1, 0)
      control rvb, mix: get(:s2, 0)
      control fla, mix: o(12, 'flanger', 0)
      control lpf, cutoff: 10 + (1.0 - get(:s4, 0)) * 130

      slices = 1 + get(:k8, 0) * 100

      sample sam,
        amp: v * 2,
        num_slices: slices,
        slice: (slices * n).to_i,  # note determines slice
        # onset: (slices*n).to_i,
        attack: 0.01,
        # norm: 1,
        # decay:0.9,
        pan: g(:pb, 0),
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
