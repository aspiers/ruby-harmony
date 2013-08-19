#!/usr/bin/ruby

require 'note'
require 'scale_finder'
require 'mode_in_key'
require 'chord_type'

def usage
  me = File.basename($0)
  $stderr.puts "Usage: #{me} KEY CHORD-TYPE [VERBOSITY]"
  exit 1
end

usage if ARGV.size < 2

starting_note_name, chord_type, verbosity = ARGV
verbosity = verbosity.empty? ? 1 : verbosity.to_i

starting_note = Note.by_name(starting_note_name)
puts ModeInKey.output_modes(starting_note) if verbosity > 1
scales = ModeInKey.all(starting_note).flatten

fixed_chord_notes = ChordType[chord_type].notes(starting_note)
descr = "%s%s" % [ starting_note_name, chord_type ]
scalefinder = ScaleFinder.new(fixed_chord_notes, descr, scales)
scalefinder.set_verbosity(verbosity)
scalefinder.run('ly/out.ly')
puts
