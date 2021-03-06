# TODO:
# - accents shorter, i.e. dur * 0.95 - no, if anything longr (?!)
# - currently only supports piano notation, i.e. left & right hands; support other instruments?
# - add support for 'hairpins' ie. cresc/dim dynamics
# - add time signature notation (for error checking? easier tuplets)
# - grace notes! i.e. 'c4-/' (short duration, no addition to duration of measure overall)?
# - parallel notes (starting at the same time as another note/chord, but with different duration)
# - 'legato' is actually called a 'slur' (find/replace)
# - 'ritardndo' slowing down tempo notation; or other sudden tempo change notation 't10' vs 'tdef/tnorm' )
# DBG = true
DBG = false

# MONSTER REGEX TO TEST FOR WELL-FORMED TOKENS:
# TODO: regex does not validate:
# - that tuplet square brackets close in the same measure they are opened
# - that tied-note parentheses are eventually closed (before the next is opened)
NOTE_DYNAMICS = '(P|pp|p|mp|a|mf|f|ff|F|fff)'  # 'a' => accent
NOTE_DURATION = '(w|h|q|e|s|t)'
NOTE_NAME = '( ([a-gA-GrR]{1} [BbSs]? \d{1}) | [Rr] )'  # note name and octave number, or rest
NOTE_OR_CHORD = "#{NOTE_NAME} (,#{NOTE_NAME})*"
DOTS = '\.{,3}'
FLOAT = '(\d*\.)?\d+'
VALID_TOKENS = Regexp.union([
  /^ \d* : $/x,  # measure indicator (number is optional - to omit means left hand/bass clef for same measure)
  /^ ped $/x,    # pedalling indicator
  /^ t (#{FLOAT})? $/x, # tempo change
  /^ #{NOTE_DYNAMICS} $/x,  # dynamics marking
  /^ ( \[ | ( \] \d+ #{NOTE_DURATION} \d+ ) ) $/x,  # tuplet groupings: opening, and closing with timing values
  /^ \(? #{NOTE_OR_CHORD} - #{NOTE_DURATION} #{DOTS} ( - #{NOTE_DYNAMICS} )? _? \)? $/x, # note/chord
])


def dcl(*args)
  cl(*args) if DBG
end

def cls(*args)
  cl *args, file:'score.pi.log'
end

def pretty(o)
  JSON.pretty_generate(o)
end

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
  # Logic Pro mapping, from (https://en.wikipedia.org/wiki/Dynamics_(music))
  # h = {
  #   'P'   => 33,
  #   'pp'  => 33,
  #   'p'   => 49,
  #   'mp'  => 64,
  #   'mf'  => 80,
  #   'f'   => 96,
  #   'ff'  => 112,
  #   'F'   => 112,
  #   'fff' => 126,
  #   :accent => 8
  # }

  h = {
    'P'   => 50,
    'pp'  => 50,
    'p'   => 75,
    'mp'  => 80,
    # 'a'   => 96,
    'mf'  => 100,
    'f'   => 110,
    'ff'  => 120,
    'F'   => 120,
    'fff' => 126,
    :accent => 9 #7
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

def get_duration( str, legato:false, debug_token:'' )

  mult = 1.0 #1.1
  legato_mult = 1.05

  f = str.to_f
  return f if f > 0

  # handle dotted notes
  if str.end_with?('...')
    # cl "TRIPLE (token: #{debug_token || '[not given]'})".red
    # TODO: regex to count dots instead of all these conditions?
    mult = 1.875   # (1 + 0.5 + 0.25 + 0.125 = 1.875)
    str = str[0..-4] # remove from end
  elsif str.end_with?('..')
    mult = 1.75
    str = str[0..-3] # remove from end
  elsif str.end_with?('.')
    mult = 1.5
    str = str[0..-2] # remove from end
  end

  dur = duration_map[ str ]

  if legato
    # cl "LEGATO: #{  [ (duration_map[str] * mult), duration_map[str] ].inspect }".red
    [ (dur * mult * legato_mult), dur * mult ]  # return unique duration and sleep time as array
  else
    # cl "NO LEGATO: #{ duration_map[str] } (#{str})"
    dur * mult   # return single duration value
  end
end

def generate_tuplet_timings(tuplets, beats, noteval, num_tuplets)
  beats = beats.to_i
  noteval = duration_map[ noteval ] # duration of bar-note
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
  velocity_map.fetch(token, nil)  # check if token is a valid key and return timing float, otherwise nil
end

def get_velocity(vel, loud)
  if vel.to_f > 0
    vel.to_f     # use specified number
  elsif vel == 'a'
    # accent adds a small amount to the marked velocity
    (loud || velocity_map[:default_vel])  + velocity_map[ :accent ]
  elsif velocity_map.has_key?( vel )
    velocity_map[ vel ]  # use specified symbol
  elsif loud
    loud         # use dynamic marker given for measure
  else
    # TODO: should never actually reach here because dynamic markers always specified?
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
      # (TODO: this will cause a tied note that stays within the same measure to have a 2-element
      #  array with the same dur & sleep values, i.e. [0.5, 0.5], in which case it should just be a scalar 0.5)
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

def score_parse(s, debug_start:0, debug_label:'')
  # process each chord-or-note
  measure = -1
  # loudness = nil
  loudness = {
    l: velocity_map[:default],
    r: velocity_map[:default]
  }
  tuplets_from = nil
  hand  = :r

  # state = { l: {everything}, r: {everything} }       ????????????????????

  # Track tied notes for each hand, i.e. ties[:l][:notes] = [[:a4, :b3], 0.75, 100]
  # :notes - (first element is array of notes in chord, second element is accumulated timing as single float, third is velocity)
  # :status - indicates whether a tie group has just started (:start), is mid-progress (:in_progress), or just ended (:end),
  # based on finding the parentheses in the score
  # :start_measure records in which measure the tie group started, for ties which span at least two measures
  ties = {
    l: { notes:[], status:nil, start_measure:nil },
    r: { notes:[], status:nil, start_measure:nil }
  }

  # keep track of notes played between pedal press - NOPE: this should happen in play_score_measure()
  pedal_held_notes = []

  s.inject( {l: [], r: []} ) do |score_acc, token|
    # cl "start: ", score_acc.inspect

    unless token.match( VALID_TOKENS )
      cl "BAD TOKEN: #{debug_label} m#{measure+1}:".red + "'#{token}'".yellow
      raise "BAD TOKEN: #{debug_label} m#{measure+1}: '#{token}'"
    end

    # pedalling
    if token == 'ped'
      score_acc[hand][measure] << :pedal
      next score_acc
    end

    # tempo change : 't0.5' / 't.5' / 't2', or 't' to revert
    # NOTE: requires 'BPM' constant to be set for piece
    # TODO: must be specified for both hands to prevent falling out of sync (FIXME)
    if token.downcase.start_with? 't'
      factor = token[1..-1].to_f
      factor = 1.0 if factor == 0.0  # no tempo value given means revert to default or starting tempo
      cl "GOT TEMPO TOKEN #{token}: #{factor} (def: #{BPM})".red
      score_acc[hand][measure] << factor  # this means the indicator for tempo change is just a naked float (TODO: flag it better? in a symbol or?)
      next score_acc
    end

    # check for N: measure numbers
    if check_set_measure(token)
      measure += 1
      hand = :r
      # loudness = nil
      # cl "RIGHT, #{ measure }"
      score_acc[:r][measure] = []
      next score_acc
    end

    # switch from right to left hand (i.e. treble to bass clef) of same measure
    if token == ':'
      hand = :l
      # loudness = nil
      # cl "LEFT, #{ measure }"
      score_acc[:l][measure] = []
      next score_acc
    end

    # set loudness from token anywhere in measure, for rest of measure (unless specifically overwritten)
    # CORRECTION: the dynamic marker should apply until *the next marker*, not just until end of measure
    # if loudness[hand] = check_for_dynamics(token, loudness[hand])
    if loud = check_for_dynamics(token)
      loudness[hand] = loud
      next score_acc
    end

    # check for '[ a b c ]1q5' tuplet notation; falsey return indicates no tuplets, nothing to do
    if t = check_for_tuplets(token, tuplets_from)
      if t.any?
        # array of notes returned indicates tuplet group has finished, so append calculated tuplet notes to score
        score_acc[hand][measure] += t
        tuplets_from = nil  # reset to 'not within a tuplet group' state
      else
        # empty array indicated new tuplet group, so reset tracking array
        tuplets_from = []
      end

      # cl "t = #{ t.inspect }".light_green
      next score_acc  # skip further process for this token
    end

    leg = false
    if chomped = check_legato(token)
      token = chomped
      leg = true
    end

    # check for parentheses indicating tie groups, and remove from token
    token, ties[hand][:status] = check_tie( token, ties[hand][:status] )

    notes, dur, vel = token.split('-')

    # cl "DURATION m=#{measure} ('#{token}'): #{ dur.inspect }, leg: #{leg}".yellow if measure==54
    dur = get_duration(dur, legato: leg, debug_token: token)
    # cl "DURATION GOT: #{ dur.inspect }, #{ dur.class }".yellow if measure==54

    vel = get_velocity(vel, loudness[hand])

    if tuplets_from
      # append notes to tuplet list instead of actual score
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
  ped = opts[:pedal]
  hand = opts[:hand]
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

    if ped && ped[ hand ]
      cl "PEDAL from inside play_score_note: #{ped.inspect}" #if opts[:hand] = :l
      cl "BPM: #{current_bpm}".green
      ped[ hand ]  << n[0]
      # cl "P ADD #{n[0]}, #{hand}"
      dur = 10000  # effectively disable note-off
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

  # need this accumulator array passed in from calling context, to remember lists of played notes which might stretch across more than one measure
  pedal_notes = opts[:pedal_notes]

  stop unless score[:l][measure_num] && score[:r][measure_num] && (!@stop || !defined?(@stop))
  cl "=== measure #{measure_num + 1} =========================="

  # if opts[:pan_hands]
  #   pan_spread = (opts[:pan_hands] * 63).to_i
  #   pan = { l: 64+pan_spread, r: 64-pan_spread }
  #   cl pan.inspect
  #   opts.delete :pan_hands
  # else
  #   pan = { l: opts[:pan] || 64, r: opts[:pan] || 64 }
  #   cl "NO PAN SPREAD, pan=#{opts[:pan]}".red
  # end

  if opts[:pan]
    # option pan: [1-127] is passed to midi() and pans both hands to the amount specified
    pan_l = opts[:pan]
    pan_r = opts[:pan]
    opts.delete :pan
  elsif opts[:pan_hands]
    # option pan_hands: [0..1] determines how far apart to spread the two piano hands
    # pan_hands:0 is no panning, equally in L & R channels
    # pan_hands:1 is full panning, left hand exclusively in left channel, right hand in right
    pan_spread = (opts[:pan_hands] * 63).to_i
    pan_l = 64 + pan_spread
    pan_r = 64 - pan_spread
    opts.delete :pan_hands
  end

  in_thread do
    score[:l][measure_num].each do |m|
      if m == :pedal
        # cl "GOT PEDAL (RL m#{measure_num} #{pedal_notes[:l].inspect}".green
        pedal_notes[:l].uniq.each{ |n| midi_note_off n, **opts } if pedal_notes[:l]
        pedal_notes[:l] = []
        next
      elsif m.is_a? Float
        use_bpm (BPM * m)  # tempo change
        cl "BPM L #{current_bpm}".red

        next
      end

      play_score_note(m, pan: pan_l, hand: :l, pedal: pedal_notes, **opts)
    end
  end

  # in_thread do    # NO! only one thread, otherwise 0 time elapses!
    score[:r][measure_num].each do |m|
      if m == :pedal
        # cl "GOT PEDAL (R) m#{measure_num} #{pedal_notes[:r].inspect}".green
        # midi_all_notes_off channel: opts[:channel]  # (this MUST be in non-thread hand) TODO: causes following notes to be cut short, occasionally!
        pedal_notes[:r].uniq.each{ |n| midi_note_off n, **opts }  if pedal_notes[:r]
        pedal_notes[:r] = []
        next
      elsif m.is_a? Float
        use_bpm (BPM * m)  # tempo change
        cl "BPM R #{current_bpm}".red
        next
      end

      play_score_note(m, pan: pan_r, hand: :r, pedal: pedal_notes, **opts)
    end
  # end
end

def validate_score(score, label:'')
  l = score[:l]
  r = score[:r]

  l.each_with_index do |measure_l, i|
    measure_r = r[i]
    if defined?( DBG ) && DBG
      cl "measure #{label} #{i+1}  left: #{measure_l.inspect}"
      cl "measure #{label} #{i+1} right: #{measure_r.inspect}"
    end
    measure_duration_l = 0
    measure_duration_r = 0
    measure_l.each do |notes|
      dur = notes[0][1]  # just get the first note (i.e. not all notes in a chord)
      if dur.is_a?(Array)
        measure_duration_l += dur[1]
      else
        measure_duration_l += dur
      end
      # notes.each do |note_value, durations, vel|
      #   cl "m(#{i}): notes #{note_value.inspect}; dur #{durations.inspect}; vel #{vel.inspect}"
      # end
    end
    measure_r.each do |notes|
      dur = notes[0][1]  # just get the first note (i.e. not all notes in a chord)
      if dur.is_a?(Array)
        measure_duration_r += dur[1]
      else
        measure_duration_r += dur
      end
      # notes.each do |note_value, durations, vel|
      #   cl "m(#{i}): notes #{note_value.inspect}; dur #{durations.inspect}; vel #{vel.inspect}"
      # end
    end
    # cl "MEASURE l:#{i+1}: dur #{measure_duration_l}".red
    # cl "MEASURE r:#{i+1}: dur #{measure_duration_r}".green
    # ignore god damned CPU rounding errors
    if (measure_duration_r - measure_duration_l).abs > 0.00000000001
      cl "MEASURES FOR #{label} #{i+1} mismatched: l=#{measure_duration_l}, r=#{measure_duration_r}".red
      raise "Measure #{label} #{i+1} not equal"
    end
  end
end

# cl "Loaded score-parser.pi.rb"
