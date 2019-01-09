# TODO: hash of keys status: held/not held, array of currently held keys & vels

live_loop :launchkey_events do
  path, key, vel = sync '/midi/launchkey_mk2_49_launchkey_midi/*/*/*', path: true
  handle_launchkey_event(path.split('/').last.to_sym, key, vel)
end

def handle_launchkey_event(type, key, vel)
  # cl type, key, vel
  case type
  when :note_off, :note_on then set("note#{key}", vel)
  end
  return unless @launchkey_handlers[type]
  @launchkey_handlers[type].call( key, key_norm(key), vel )
end

def key_held(key)
  get("note#{key}") > 0
end

def key_norm(key)
  (key - 36) / 48.0   # key start-end: 36-84, keyrange = 48
end

@launchkey_handlers = {
  note_on: nil,
  note_off: nil,
  control_change: nil
}
# @launchkey_notes = Hash.new(0)

# method to attach handlers for events (:note_on, :note_off, :control_change, :pitch_bend)
# block gets args: key, key_normalised, velocity
def kbd(event, &block)
  # shorter names
  event = case event
    when :on  then :note_on
    when :off then :note_off
    when :cc  then :control_change
    else event
  end

  @launchkey_handlers[event] = block
  # cl "handler SET", event, block
end
