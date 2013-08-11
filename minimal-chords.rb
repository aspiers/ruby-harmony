#!/usr/bin/ruby

require 'note'
require 'scale_finder'
require 'scale_in_key'
require 'chord_type'

key_name, chord_type, verbosity = ARGV

key = Note.by_name(key_name)
puts ModeInKey.output_modes(key)

fixed_chord_notes = ChordType[chord_type].notes(key)
descr = "%s%s" % [ key_name, chord_type ]
scalefinder = ScaleFinder.new(fixed_chord_notes, key_name, descr)
scalefinder.set_verbosity(verbosity.to_i)
scalefinder.run('ly/out.ly')
puts
