
# with_fx :ixi_techno do |ixi|
with_fx :level, amp: 1 do |amp|
with_fx :lpf, slide: 0.1 do |lpf|
with_fx :distortion, mix: 0 do |dist|
with_fx :reverb, mix: 0 do |rvb|
with_fx :flanger, mix: 0 do |fla|

live_loop :launchkey_events do

  # fx
  # control ixi, phase: get(:mod,0) * 4
  # control amp, amp: get(:mod,0)*2
  control amp, amp: key_fx(:amp) * 4
  control rvb, mix: key_fx(:reverb)
  control fla, mix: key_fx(:flanger)
  control lpf, cutoff: 10 + (1.0 - key_fx(:lpf)) * 130
  control dist,
    mix: key_fx(:dist_mix),
    distort: key_fx(:dist_distort) * 0.99

  path, key, vel = sync '/midi/launchkey_mk2_49_launchkey_midi/*/*/*', path: true
  handle_launchkey_event(path.split('/').last.to_sym, key, vel)
end

end # fx
end
end
end
end

def cc_to_symbol(cc)
  case cc
    when 1       then :mod
    when 7       then :master
    when 64      then :pedal
    when 21..28  then "k#{cc-20}"
    when 41..48  then "s#{cc-40}"
    else              "cc#{cc}"
  end
end

# AUTOMATICALLY set()s the following:
# :noteN values, :ccN vales, :kN values for knobs 1-8, :sN values for sliders 1-8 (all 0..1)
# :pedal/:ped value for foot/hold pedal (0/127)
# :master value for master slider (0..1)
# use i.e. get(:cc55, 0) to get the value, defaulting to 0
def handle_launchkey_event(type, key, vel)
  # cl type, key, vel
  case type
  when :note_off, :note_on then set( "note#{key}", vel / 127.0 )
  when :control_change     then set( cc_to_symbol(key), vel / 127.0 )
  when :pitch_bend         then set( :pb, key / 16383.0 )
  end

  return unless @launchkey_handlers[type]
  @launchkey_handlers[type].call( key, key_norm(key), vel / 127.0 )
end

def key_held(key)
  get("note#{key}") > 0
end

def key_norm(key)
  (key - 36) / 48.0   # key start-end: 36-84, keyrange = 48
end

def event_aliases(event)
  case event
    when :on   then :note_on
    when :off  then :note_off
    when :cc   then :control_change
    when :ped  then :pedal
    when :m    then :master
    when :pb   then :pitch_bend
    else event
  end
end

# shortcut to get(), which also checks event aliases (TODO: this only makes sense for :m and :ped)
def g(sym, default=0)
  get(event_aliases(sym), default)
end

@launchkey_handlers = {
  note_on: nil,
  note_off: nil,
  control_change: nil
}
# @launchkey_notes = Hash.new(nil)

# kbd(): attach handler for an event (:note_on, :note_off, :control_change, :pitch_bend)
# block gets args: key, key_normalised, velocity (normalised)
def kbd(event, &block)
  @launchkey_handlers[ event_aliases(event) ] = block
end

cl "Launchkey lib: loaded"

@launchkey_fx_controls = {}
def set_fx_controls(h)
  @launchkey_fx_controls.merge! h
  cl h.inspect
end

def key_fx(key, default=0)
  get(@launchkey_fx_controls[key], default)
end
