# TODO:
# accents shorter, i.e. dur * 0.95
# group m/f/p notations in brackets
#  - possibly at start of bar? own token?
# currently only supports piano notation, i.e. left & right hands; support other instruments?

DBG = true
DBG = false


def dcl(*args)
  cl(*args) if DBG
end

def pretty(o)
  JSON.pretty_generate(o)
end

  # durations lookup
  @dur = Hash.new(0.25)
  @dur['t'] = 0.03125
  @dur['s'] = 0.0625
  @dur['e'] = 0.125
  @dur['q'] = 0.25
  @dur['h'] = 0.5
  @dur['w'] = 1

  # @bar['t'] = 32
  # @bar['s'] = 16
  # @bar['e'] = 8
  # @bar['q'] = 4
  # @bar['h'] = 2
  # @bar['w'] = 1

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

def duration_map
  h = {
    't' => 0.03125,
    's' => 0.0625,
    'e' => 0.125,
    'q' => 0.25,
    'h' => 0.5,
    'w' => 1
  }
  h.default = 0.25
  h
end

def velocity_map
  h = {
    'P'   => 50,
    'pp'  => 50,
    'p'   => 75,
    'mp'  => 80,
    'a'   => 96,
    'mf'  => 100,
    'f'   => 110,
    'ff'  => 120,
    'F'   => 120,
    'acc' => 6
  }
  h.default = 90
  h
end

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

  mult = 1.0 #1.1

  f = str.to_f
  return f if f > 0

  # handle double-dotted and dotted notes
  if str.end_with?('..')
    mult = 1.75
    str = str[0..-3] # remove from end
  elsif str.end_with?('.')
    mult = 1.5
    str = str[0..-2] # remove from end
  end

  dur = duration_map[ str ]

  if legato
    mult = 1.05
    # cl "LEGATO: #{  [ (@dur[str] * mult), @dur[str] ].inspect }".red
    [ (dur * mult), dur ]  # return unique duration and sleep time as array
  else
    # cl "NO LEGATO: #{ @dur[str] }"
    dur * mult   # return single duration value
  end

end

def generate_tuplet_timings(tuplets, beats, noteval, num_tuplets)
  beats = beats.to_i
  noteval = @dur[ noteval ] # duration of bar-note
  bar = 1.0/noteval         # beats/bar is the time signature
  num_tuplets = num_tuplets.to_f
  # cl "FOUND END #{beats} / #{noteval} : #{num_tuplets}"
  # cl "Tuplets INPUT: #{tuplets.inspect}".blue
  # # cl "note: '#{note.inspect}', dur: '#{dur.inspect}', vel: '#{vel.inspect}', beats: '#{beats.inspect}'"

  # pure trial and error, no idea *why* this is true, just seems to give
  # correct value when multipled by note duration
  # (i.e. mult = 0.8 for 2/4 time, with tuplets of 5)

  # this is wrong - it gives longer note durations for i.e. 4e5 than it does for 4q5
  mult = (beats / num_tuplets) / (beats * noteval)

  # mult = (beats*num_tuplets / noteval) / (beats / bar)
  # cl "bar: #{bar}, noteval: #{noteval}  mult: #{mult}"
  # m = 2/0.5 = 0.5 * 5   # (tuplets / beats) * bar's

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
  # cl "VEL: #{@vel.inspect}".green
  velocity_map.fetch(token, nil)  # check if token is a valid key and return timing float, otherwise nil
end

def get_velocity(vel, loud)
  if vel.to_f > 0
    vel.to_f     # use specified number
  elsif velocity_map.has_key?( vel )
    velocity_map[ vel ]  # use specified symbol
  elsif loud
    loud         # use dynamic marker given for measure
  else
    velocity_map[ :default_vel ]  # user default hash value
  end
end

def check_tie(token, status)
  if token.start_with? '('
    token = token[1..-1]  # trim first character
    return [token, :start]
  elsif token.end_with? ')'
    token = token.chomp ')'
    return [token, :end]
  end
  [token, status]  # pass back original values
end



def process_tied_notes( notes, duration, velocity, measure_num, tie_hand, score_hand )

  if tie_hand[:status] == :start
    # cl "Tie START m(hand??, #{measure_num+1})".green

    # save note starting values for this tie group, including distinct [duration, sleep] times
    tie_hand[:notes] = notes.split(','), [duration, duration], velocity
    # store the measure at which the tie began (for those which cross measures)
    tie_hand[:start_measure] = measure_num
    # advance state
    tie_hand[:status] = :in_progress
  else
    # this code runs for both :in_progress and :end tie statuses (i.e. any but :start status)

    # cl "adding to m(hand??, #{measure_num+1}): tie_hand(#{tie_hand[:notes]}): duration #{duration}".green

    # add trailing tied-note duration to running total
    tie_hand[:notes][1][0] += duration  unless notes == 'r'

    if measure_num == tie_hand[:start_measure]
      # add duration to tie's *sleep* time instead (keep simultaneous same measures in sync)
      tie_hand[:notes][1][1] += duration  unless notes == 'r'
    else
      # add rest to score if not in starting measure (keeps simultaneous subsequent measures in sync)
      score_hand[measure_num] << [[:r, duration, 0]]
    end

    if tie_hand[:status] == :end
      # just runs at end of tie, i.e. closing ')' - save final tied note duration back to original note in score
      # cl "Tie END".red, "adding to final tie_hand(#{tie_hand[:notes]}): duration #{duration}".blue

      # add to measure_num at which the tie started
      score_hand[ tie_hand[:start_measure] ] << split_notes( *tie_hand[:notes] )
      # reset tie state
      tie_hand[:status] = nil
    end

  end

  [score_hand, tie_hand]  # return both
end

def score_parse(s, debug_start:0)
  # process each chord-or-note
  measure = -1
  loudness = nil
  tuplets_from = nil
  hand  = :r
  # Track tied notes for each hand, i.e. ties[:l][:notes] = [[:a4, :b3], 0.75, 100]
  # :notes - (first element is array of notes in chord, second element is accumulated timing as single float, third is velocity)
  # :status - indicates whether a tie group has just started (:start), is mid-progress (:in_progress), or just ended (:end),
  # based on finding the parentheses in the score
  # :start_measure records in which measure the tie group started, for ties which span at least two measures
  ties = {
    l: { notes:[], status:nil, start_measure:nil },
    r: { notes:[], status:nil, start_measure:nil }
  }


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

    # check for parentheses indicating tie groups, and remove from token
    token, ties[hand][:status] = check_tie( token, ties[hand][:status] )

    notes, dur, vel = token.split('-')

    dur = get_duration(dur, legato: leg)
    # cl "DURATION GOT: #{ dur.inspect }, #{ dur.class }".yellow

    vel = get_velocity(vel, loudness)

    if tuplets_from
      tuplets_from << split_notes(notes, dur, vel)
      # cl "SPLIT: ", tuplets_from.last.inspect; # cl "TUP PUSH", tuplets_from.inspect
    elsif ties[hand][:status]
      # handle tied notes
      score_acc[hand], ties[hand] = process_tied_notes( notes, dur, vel, measure, ties[hand], score_acc[hand] )
      # cl "tie-measure(#{hand}, #{measure_num+1}): #{score[hand][measure_num].inspect}".red #if measure_num >= debug_start
    else
      # not a tuplet or tie group: i.e. standard append of notes to score
      score_acc[hand][measure] << split_notes(notes, dur, vel)
    end

    # cl "FINAL ts:#{ties[hand][:status]}, m(#{hand}, #{measure+1}): #{score_acc[hand][measure].inspect}".blue # if measure >= debug_start

    score_acc
  end # inject
end # def score_parse()

def split_notes(notes, dur, vel)

  # handle an array of notes (i.e. from tied-group) or a string of comma-separated notes
  note_list = notes.is_a?(Array) ? notes : notes.split(',')

  # split a potential chord into an array of notes with the same duration and velocity
  note_list.inject([]) do |ac, note|
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
  zzz || z_candidate  # return time slept
end

# play a single measure by number, both hands
def play_score_measure(score, measure_num, opts = {})

  stop unless score[:l][measure_num] && score[:r][measure_num] && (!@stop || !defined?(@stop))
  cl "=== measure #{measure_num + 1} =========================="
  in_thread do
    measure_time_l = 0
    score[:l][measure_num].each { |m| measure_time_l += play_score_note(m, **opts) }
    # cl "TOTAL MEASURE TIME(:l, #{measure_num+1}) = #{ measure_time_l }"
  end
  # in_thread do    # NO! only one thread, otherwise 0 time elapses!
    measure_time_r = 0
    score[:r][measure_num].each { |m| measure_time_r += play_score_note(m, **opts) }
    # cl "TOTAL MEASURE TIME(:r, #{measure_num+1}) = #{ measure_time_r }"
  # end
end

cl "Loaded score-parser.pi.rb"
