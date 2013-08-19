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

key_name, chord_type, verbosity = ARGV
verbosity = verbosity.empty? ? 1 : verbosity.to_i

key = Note.by_name(key_name)
puts ModeInKey.output_modes(key) if verbosity > 1

fixed_chord_notes = ChordType[chord_type].notes(key)
descr = "%s%s" % [ key_name, chord_type ]
scalefinder = ScaleFinder.new(fixed_chord_notes, key_name, descr)
scalefinder.set_verbosity(verbosity)
scalefinder.run('ly/out.ly')
puts
