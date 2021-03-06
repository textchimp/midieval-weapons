# Defines:
#     @grid[ PAGES=1 ][ ROWS=8 ][ COLS=8 ]
#        - cell values are 0 or 1
#
#      @buttons[ 64 ]
#        - values are true/false, no row/col subindexes
#
#
#      beat_marker(current_beat, num_beats=8)
#        - activate marker light (top row circular buttons) at current beat
#
# TODO:
#
#  - instantaneous hold value state for all buttons
#  - define callbacks for specific buttons (i.e circular control buttons)
#  - set range of push states (and colours) for all rows/buttons?
#
# see /build/sonicpi/sonic-pi-launchpad.pi.rb for most code

use_midi_defaults channel: 1, port: "launchpad_mini"
@held = {}
PAGES = 1
CC_START = 104   # start of top row of circular buttons

def num_to_lp(n)
  quot, rem = n.divmod 8
  quot*16 + rem
end

# play 50
@clr = {
  green: 56,
  yellow: 127,
  red: 7,
  orange: 83,
  wgreen: 105,
  wyellow: 102,
  wred: 75,
  worange: 107,
}
def clr(val); @clr.fetch(val); end

# reset board
# midi_raw 176, 0, 0, channel: 1, port: "launchpad_mini"


def beat_marker(beat, beats=8)
  last = (beat == 0) ? beats-1 : beat-1
  midi_cc CC_START + last, value: 0, port: "launchpad_mini"
  midi_cc CC_START + beat, value: 1, port: "launchpad_mini"
end

if defined?(@page).nil?
  @page = 0
end

@off_check = nil
def button_off_check(grid, &block)
  return unless block_given?
  cl "check!", &block
  # @off_check = block
  # cl @off_check.to_s
end

# def on_buttons
 #  @buttons.reduce([]) do |accum, item, i|
 #    puts accum, item, i
 # end
# end

def send_grid(g)
  g.each_with_index do |x, xi|
    x.each_with_index do |y, yi|
      midi_note_on (xi * 16 + yi), vel_f: g[xi][yi]
    end
  end
end

def clear_grid
  puts "CLEAR"

  @buttons = Array.new(64, false)

  PAGES.times do |p|
    @grid[p].each_with_index do |x, xi|
      (x + [0]).each_with_index do |y, yi|
        # weird "+ [0]" here to clear additional buttons on right edge
        @grid[p][xi][yi] = 0
        midi_note_off (xi * 16 + yi)
      end
    end
  end
end


def grid_print
  @grid.each_with_index do |x|
    puts x
  end
end


class Seq
  attr_accessor :grid, :beat

  def initialise(cols, rows, pages=PAGES)
    @grid = Array.new(pages){    Array.new(rows){ Array.new(cols){0} }    }
  end
end



if defined?(@grid).nil?
  # first time, init grid
  # @grid = Array.new(8){ Array.new(8){0} }
  @grid = Array.new(PAGES){    Array.new(8){ Array.new(8){0} }    }
  clear_grid
  @buttons = Array.new(64, false)
else
  # send existing grid
  send_grid(@grid[@page])
end


def cell_update(page, row, col, note)
  half = 0.1
  index = (row * 8) + col
  puts "CELL: #{ @grid[page][row][col] }"
  # cl "grid update:\n #{@grid[page]}"
  # cl "#{row}:#{col} = #{note} "
  if @grid[page][row][col] == 1

    if row == 6 || row == 7
      @grid[page][row][col] = half
    else
      @grid[page][row][col] = 0
      @buttons[ index ] = false
    end

  elsif @grid[page][row][col] == half
    @grid[page][row][col] = 0
    @buttons[ index ] = false
  else
    @grid[page][row][col] = 1
    @buttons[ index ] = true
  end

  midi_note_on note, vel_f: @grid[page][row][col]
end

# get the value of the sequencer cell using a one-dimensional index
def cell(ind)
  row = (ind / 8).to_i
  col = ind % 8

  @grid[@page][row][col]
end

live_loop :launchpad_note do
  note, vel = sync "/midi/launchpad_mini/*/1/note_on"
  # puts note, vel


  row = (note / 16).to_i
  col = note % 16

  # generate a one-dimensional array index from the launchpad note values
  index = (row * 8) + col
  puts "note: #{ note }, index: #{index}"

  # grid_print # puts "GRID: #{ (note / 16).to_i}, #{note % 16}"
  if vel > 0
    @held[note] = true
    # puts row, col
    if col < 8
      cell_update(@page, row, col, note)
    end
  else
    # vel 0
    @held[note] = false
  end
  puts "CELL VAL: ", cell( index )

  # on_buttons()

end



live_loop :launchpad_cc do
  # use_real_time
  cc, val = sync "/midi/launchpad_mini/*/1/control_change"
  if val > 0
    case cc
    when 111
      clear_grid
    end
  else
    # button release
    # case cc
    # when 107
    # end
  end

end

cl "HERE"
