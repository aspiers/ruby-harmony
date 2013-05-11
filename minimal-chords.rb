#!/usr/bin/ruby

require 'set'
require 'pp'

$verbosity = ARGV.shift.to_i || 0

NOTES = [ 'C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B' ]

class ScaleType
  @@all = [ ]

  attr_reader :name, :increments, :symmetry

  def initialize(name, increments, symmetry)
    @name = name
    @increments = increments
    @@all.push self
    @index = @@all.length - 1
  end

  new('maj',      [ 2, 2, 1, 2, 2, 2, 1    ], 7)
  new('mel min',  [ 2, 1, 2, 2, 2, 2, 1    ], 7)
  new('harm min', [ 2, 1, 2, 2, 1, 3, 1    ], 7)
  new('harm maj', [ 2, 2, 1, 2, 1, 3, 1    ], 7)

  # new('whole',    [ 2, 2, 2, 2, 2, 2       ], 1)
  # new('dim',      [ 2, 1, 2, 1, 2, 1, 2, 1 ], 2)
  # new('aug',      [ 3, 1, 3, 1, 3, 1       ], 2)
  # new('dbl harm', [ 1, 3, 1, 2, 1, 3, 1    ], 7)

  def ScaleType.all; @@all end
  def inspect;       name  end
end

class NoteArray < Array
  def note_names; map { |note| NOTES[note] } end
  def to_s;       note_names.map { |n| "%-2s" % n }.join " " end
end

Mode = Struct.new(:degree, :scale_type, :index) do
  DEGREES = %w(ion dor phryg lyd mixo aeol loc)

  # rotate intervallic increments by different degrees of the scale
  # to generate the 7 modes for this scale type
  def increments
    scale_type.increments.rotate(degree)[0...-1]
  end

  # convert intervallic increments into numeric pitches
  # relative to the root (0)
  def notes
    @notes ||= increments.inject(NoteArray.new [0]) do |array, note|
      array.push(array.last + note)
    end
  end

  def to_s
    deg = DEGREES[degree]
    return deg if scale_type.name == 'maj'
    "%s %s" % [ deg, scale_type.name ]
  end

  def <=>(other)
    index <=> other.index
  end
end

def all_modes # builds all 28 modes
  @@modes ||= \
  begin
    modes = [ ]
    ScaleType.all.each do |scale_type|
      degree = 3 # start with lydian
      begin
        mode = Mode.new(degree, scale_type, modes.length - 1)
        modes.push mode
        debug 2, "%-15s %s" % [ mode, mode.notes.to_s ]
        degree = (degree + 4) % 7 # move through modes from open to closed
      end while degree % 7 != 3 # stop when we get back to lydian
      debug 2, ''
    end
    debug 2, ''
    modes
  end
end

def debug(level, msg)
  puts msg if level <= $verbosity
end

def modes_matching_chord(chord)
  all_modes.find_all { |mode| (chord & mode.notes).length == chord.length }
end

identifiers = Hash[ all_modes.map { |mode| [mode, {}] } ]

for chord_size in 3..7
  debug 1, "Checking all #{chord_size}-note chords ..."
  for chord in (1..11).to_a.combination(chord_size - 1) # exclude root
    matches = modes_matching_chord(chord)
    chord = NoteArray.new([0] + chord)
    case matches.length
    when 0
      debug 2, "    #{chord} didn't match any modes"
    when 1
      identified_mode = matches[0]
      debug 1, "*   #{chord} uniquely identified: #{identified_mode}"
      identifiers[identified_mode][chord_size] ||= [ ]
      identifiers[identified_mode][chord_size].push chord
    else
      matches_to_show = matches.dup
      if $verbosity == 2
        matches_to_show = matches.first(2)
        matches_to_show += [ '...' ] if matches.length > 2
      end
      debug 2, ".   #{chord} matched #{matches.length} modes: " + \
        matches_to_show.join(', ')
    end
  end
  debug 1, ''
end

debug 1, "-" * 72
debug 1, ''
puts <<EOF
Summary
=======

EOF

modes_by_chord_size = { }
distinctiveness = { }

identifiers.sort.each do |mode, chords_by_size|
  if chords_by_size.empty?
    modes_by_chord_size[0] ||= [ ]
    modes_by_chord_size[0].push mode
    puts "no chords found uniquely identifying #{mode}!"
    next
  end

  size, chords = chords_by_size.sort.first
  modes_by_chord_size[size] ||= [ ]
  modes_by_chord_size[size].push mode
  distinctiveness[[size, chords.size]] ||= [ ]
  distinctiveness[[size, chords.size]].push mode
  puts "#{size} note chords uniquely identifying #{mode}:"
  for chord in chords
    puts "    #{chord}"
  end
end

puts <<EOF

Modes sorted by "uniqueness" (ease of identification)
-----------------------------------------------------

EOF

for sizes, modes in distinctiveness.sort_by { |sizes, modes| [sizes[0], -sizes[1]] }
  chord_size, num_chords = sizes
  puts "modes uniquely identified by #{num_chords} #{chord_size}-note chord#{num_chords == 1 ? '' : 's'}: " + modes.join(', ')
end

puts <<EOF

How many notes are needed?
--------------------------

EOF

for size, modes in modes_by_chord_size.sort
  if size == 0
    puts "modes with no unique identifier found: " + modes.join(', ')
  else
    puts "#{modes.length} mode#{modes.length == 1 ? '' : 's'} uniquely identified by #{size} notes: " + modes.join(', ')
  end
end
