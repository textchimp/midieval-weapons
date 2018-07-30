# TODO:
# accents shorter, i.e. dur * 0.95
# group m/f/p notations in brackets
#  - possibly at start of bar? own token?

DBG = false

def dcl(*args)
  cl(*args) if DBG
end

def pretty(o)
  JSON.pretty_generate(o)
end

# if :lookup_tables
  # durations lookup
  @dur = Hash.new(0.25)
  @dur['t'] = 0.03125
  @dur['s'] = 0.0625
  @dur['e'] = 0.125
  @dur['q'] = 0.25
  @dur['h'] = 0.5
  @dur['w'] = 1

  # velocity lookup
  @vel = Hash.new(90)
  @vel['pp']  = 50; @vel['P']   = 50
  @vel['p']   = 75
  @vel['mp']  = 80
  @vel['a']   = 96
  @vel['mf']  = 100
  @vel['f']   = 110
  @vel['ff']  = 120; @vel['F']   = 120
  @vel['acc'] = 6
# end

def mplay(args  = {})  # **args
  # optional shorter keys
  args[:pan]      ||= args[:p]
  args[:channel]  ||= args[:c]
  args[:note]     ||= args[:n]
  args[:velocity] ||= args[:v]
  args[:sustain]  ||= args[:s]

  midi args[:note], **args
end

def check_set_measure(token)
  return false unless token =~ /(\d+)\:/
  $1 #return measure num
end

def get_duration( str, legato:false )

  mult = 1.05 #1.1

  f = str.to_f
  return f if f > 0

  if legato
    # cl "LEGATO: #{  [ (@dur[str] * mult), @dur[str] ].inspect }".red
    [ (@dur[str] * mult), @dur[str] ]  # return unique duration and sleep time as array
  else
    # cl "NO LEGATO: #{ @dur[str] }"
    @dur[str]  # return single duration value
  end

end

def generate_tuplet_timings(tuplets, beats, noteval, num_tuplets)
  beats = beats.to_i
  noteval = @dur[ noteval ]   # beats/noteval is the time signature
  num_tuplets = num_tuplets.to_f
  # cl "FOUND END #{beats} / #{noteval} : #{num_tuplets}"
  # cl "Tuplets INPUT: #{tuplets.inspect}".blue
  # # cl "note: '#{note.inspect}', dur: '#{dur.inspect}', vel: '#{vel.inspect}', beats: '#{beats.inspect}'"

  # pure trial and error, no idea *why* this is true, just seems to give
  # correct value when multipled by note duration
  # (i.e. mult = 0.8 for 2/4 time, with tuplets of 5)
  mult = (beats / num_tuplets) / (beats * noteval)

  tuplets.map do |notes|
    notes.map do |n, d, v|
      dur = d.is_a?(Array) ? d.map{ |e| e * mult } : d * mult
      [n, dur, v]
    end
  end
end

def check_for_tuplets(token, tuplets)
  case token
  when '['
    # START of tuplet group; [] indicates tuplets tracking array should be cleared
    []
  when /\](\d+)([a-z]+)(\d+)/
    # end of tuplets group, return array of notes with adjusted durations
    generate_tuplet_timings(tuplets, $1, $2, $3)
  else
    nil  # not found
  end
end

def check_legato(token)
   return token.chomp('_') if token.end_with?('_')
   nil
end

def check_for_dynamics(token)
  @vel.fetch(token, nil)  # check if token is a valid key and return timing float, otherwise nil
end

def get_velocity(vel, loud)
  if vel.to_f > 0
    vel.to_f     # use specified number
  elsif @vel.has_key?( vel )
    @vel[ vel ]  # use specified symbol
  elsif loud
    loud         # use dynamic marker given for measure
  else
    @vel[ :default_vel ]  # user default hash value
  end
end


def score_parse(s, key=nil)
  # process each chord-or-note
  measure = -1
  loudness = nil
  tuplets_from = nil
  hand  = :r

  s.inject( {l: [], r: []} ) do |score_acc, token|
    # cl "start: ", score_acc.inspect

    # check for N: measure numbers
    if check_set_measure(token)
      measure += 1
      hand = :r
      loudness = nil
      # cl "RIGHT, #{ measure }"
      score_acc[:r][measure] = []
      next score_acc
    end

    # switch from right to left hand (i.e. treble to bass clef) of same measure
    if token == ':'
      hand = :l
      loudness = nil
      # cl "LEFT, #{ measure }"
      score_acc[:l][measure] = []
      next score_acc
    end

    # set loudness from token anywhere in measure, for rest of measure (unless specifically overwritten)
    if loud = check_for_dynamics(token)
      loudness = loud
      next score_acc
    end

    # check for [ a b c ]1q5 tuplet notation (TODO: neater return signalling from this fn)
    if t = check_for_tuplets(token, tuplets_from)
      if t.any? # array of notes returned indicates tuplet group finished; append to score
        score_acc[hand][measure] += t
        tuplets_from = nil  # reset to 'not in tuplet group' state
      else
        tuplets_from = [] # empty array indicated new tuplet group, so reset tracking array
      end

      # cl "t = #{ t.inspect }".light_green
      next score_acc  # skip further process for this token
    end
    # cl "tuplets_from #{tuplets_from.inspect}"

    leg = false
    if chomped = check_legato(token)
      token = chomped
      leg = true
    end
    # token = check_legato(token) || token

    notes, dur, vel = token.split('-')
    dur = get_duration(dur, legato: leg)
    # cl "DURATION GOT: #{ dur.inspect }, #{ dur.class }".yellow


    vel = get_velocity(vel, loudness)


    if tuplets_from
      # cl "SPLIT: ", split_notes(notes, dur, vel).inspect; # cl "TUP PUSH", tuplets_from.inspect
      tuplets_from << split_notes(notes, dur, vel)
    else
      # cl "err: hand #{hand} measure #{measure}"
      # cl "score", score_acc.inspect
      score_acc[hand][measure] << split_notes(notes, dur, vel)  # standard append of notes
    end

    score_acc
  end # inject
end

def split_notes(notes, dur, vel)
  # split a chord string like 'a4,c5' into an array of notes with the same duration and velocity
  notes.split(',').inject([]) do |ac, note|
    ac << [
      note.to_f > 0 ? note.to_f : note.to_sym,  # use literal MIDI note number or SPi symbol
      dur,
      vel
    ]
  end
end

# play a single chord or note from the score array
def play_score_note(notes, opts = {})
  # cl "NOTES: #{notes.inspect}".red
  opts[:vscale] ||= 1.0
  zzz = nil
  z_candidate = nil

  notes.each do |n|
    if n[1].is_a? Array
      # note with legato value, i.e. different sustain & sleep values
      # TODO: if chord, last note's legato value will be used? no legato in chords?
      dur, zzz = n[1]
      # cl "n1: #{n[1].inspect}, dur: #{dur}, zzz: #{zzz}".green
    else
      dur = n[1]
      z_candidate = n[1]
    end

    dcl "mplay(note:#{n[0]}, sustain:#{n[1]}, velocity:#{n[2]})"
    mplay note:n[0], sustain:dur, velocity:n[2] * opts[:vscale], **opts
  end

  # cl "DUR: #{notes[0][1]}, SLEEP: #{notes[0][1]}"
  # sleep for either specified legato sleep time, or last-note-in-chord's duration time
  sleep zzz || z_candidate
end

# play a single measure by number, both hands
def play_score_measure(score, measure_num, opts = {})

  stop unless score[:l][measure_num] && score[:r][measure_num]

  in_thread do
    score[:l][measure_num].each { |m| play_score_note(m, **opts) }
  end
  # in_thread do    # NO! only one thread, otherwise 0 time elapses!
    score[:r][measure_num].each { |m| play_score_note(m, **opts) }
  # end
end