require 'scale_finder'
require 'chord_type'
require 'mode_in_key'
require 'note'

describe ScaleFinder do
  shared_examples "scalefinder" do |key, descr, fixed_chord_notes, expected|
    specify "finds scales including: #{fixed_chord_notes.join(' ')}" do
      scalefinder = ScaleFinder.new(fixed_chord_notes, key.name, descr)
      scalefinder.set_verbosity(0)
      scales = ModeInKey.all(key).flatten
      scalefinder.identify_modes
      scalefinder.scales.map { |scale| scale[0].name }.should == expected
    end
  end

  shared_examples "preset" do |key_name, chord_type, expected|
    key = Note[key_name]
    fixed_chord_notes = ChordType[chord_type].notes(key)
    include_examples "scalefinder", key, key_name + chord_type, fixed_chord_notes, expected
  end

  include_examples "preset", "C", "7b9", \
  [
    "5th degree of F harm min",
    "3rd degree of Ab harm maj",
    "5th degree of F harm maj",
    "4th degree of G dim"
  ]
  include_examples "preset", "C", "min11", \
  [
    "C dorian\n(2nd degree of Bb maj)",
    "C aeolian\n(6th degree of Eb maj)",
  ]
  include_examples "preset", "Db", "7#11", \
  [
    "Db lydian dominant\n(4th degree of Ab mel min)",
    "Db lydian dominant\n(4th degree of Ab mel min)",
    "Db altered\n(7th degree of Ebb mel min)",
    "Db altered\n(7th degree of Ebb mel min)",
    "Db whole tone",
    "6th degree of F dim",
    "6th degree of F dim",
    "6th degree of F dim",
    "6th degree of F dim",
  ]

  shared_examples "custom" do |key_name, descr, notes, expected|
    fixed_chord_notes = notes.split.map { |n| Note[n] }
    include_examples "scalefinder", Note[key_name], descr, fixed_chord_notes, expected
  end

  include_examples "custom", "C", "Ab/C", "C Eb Ab", \
  [
    "C phrygian\n(3rd degree of Ab maj)",
    "C aeolian\n(6th degree of Eb maj)",
    "C locrian\n(7th degree of Db maj)",
    "C locrian natural 2\n(6th degree of Eb mel min)",
    "C altered\n(7th degree of Db mel min)",
    "C harm min",
    "7th degree of Db harm min",
    "3rd degree of Ab harm maj",
    "6th degree of E harm maj",
    "7th degree of Db harm maj",
    "C dim"
  ]
end
