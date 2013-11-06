require 'scale_finder'
require 'chord_type'
require 'mode_in_key'
require 'diatonic_scale_type'
require 'symmetrical_scale_type'
require 'note'

describe ScaleFinder, slow: true do
  shared_examples "scalefinder" do
    |key, descr, fixed_chord_notes, clef, simplify, exp_total, expected|

    context "finds #{simplify ? 'simplified ' : ''}scales including: #{fixed_chord_notes.join(' ')}" do
      before(:all) {
        scale_types = [
          DiatonicScaleType.all_in_subclass,
          #PentatonicScaleType.all_in_subclass,
          SymmetricalScaleType.all_in_subclass,
        ].flatten
        catalogue = ModeInKey.from_scale_types(key, scale_types).flatten
        @scalefinder = ScaleFinder.new(fixed_chord_notes, descr, clef, catalogue)
        @scalefinder.set_verbosity(0)
        @scalefinder.enable_simplification if simplify
        @scalefinder.identify_modes
      }

      it "should find the right number of scales" do
        @scalefinder.scales_matched.size.should == exp_total
      end

      it "should find the right scales and identifiers" do
        results = @scalefinder.scales_matched.map do |scale, notes, chord|
          [ scale.name, notes.join(' '), chord.join(' ') ]
        end
        expected.each do |ename, enotes, eidents|
          results.should include([ ename, enotes.split.join(' '), eidents.split.join(' ') ])
        end
      end
    end
  end

  shared_examples "preset" do |key_name, chord_type_name, clef, fifth, simplify, exp_total, expected|
    key = Note[key_name]
    chord_type = ChordType[chord_type_name]
    chord_type = chord_type.maybe_add_fifth if fifth
    fixed_chord_notes = chord_type.notes(key)
    include_examples "scalefinder",
      key, key_name + chord_type_name, fixed_chord_notes, clef, simplify, exp_total, expected
  end

  shared_examples "treble preset" do |key_name, chord_type_name, simplify, exp_total, expected|
    include_examples "preset",
      key_name, chord_type_name, 'treble', false, simplify, exp_total, expected
  end

  include_examples "treble preset", "C", "7b9", false, 7, \
  [
    [ "C altered\n(7th degree of Db mel min)",
                                    "C4 Db4 Eb4 Fb4 Gb4 Ab4 Bb4",  "Gb4 Ab4"    ],
    [ "C dominant b9 b13\n(5th degree of F harm min)",
                                    "C4 Db4 E4 F4 G4 Ab4 Bb4",     "F4  Ab4"    ],
    [ "3rd degree of Ab harm maj",  "C4 Db4 Eb4 Fb4 G4 Ab4 Bb4" ,  "Eb4 G4 Ab4" ],
    [ "C dominant b9\n(5th degree of F harm maj)",
                                    "C4 Db4 E4 F4 G4 A4 Bb4"    ,  "F4 A4"      ],
    [ "4th degree of G diminished", "C4 Db4 Eb4 E4 F#4 G4 A4 Bb4", "Eb4 A4"     ],
    [ "4th degree of G diminished", "C4 Db4 Eb4 E4 F#4 G4 A4 Bb4", "F#4 G4"     ],
    # Don't need this since partial expectations are allowed.
    #[ "4th degree of G diminished", "C4 Db4 Eb4 E4 F#4 G4 A4 Bb4", "F#4 A4"    ],
  ]
  include_examples "treble preset", "C", "min11", false, 4, \
  [
    [ "C dorian\n(2nd degree of Bb maj)",  "C4 D4 Eb4 F4 G4  A4 Bb4" , "G4  A4"  ],
    [ "C aeolian\n(6th degree of Eb maj)", "C4 D4 Eb4 F4 G4  Ab4 Bb4", "G4  Ab4" ],
    [ "C locrian natural 2\n(6th degree of Eb mel min)",
                                           "C4 D4 Eb4 F4 Gb4 Ab4 Bb4", "Gb4 Ab4" ],
    [ "2nd degree of Bb harm maj",         "C4 D4 Eb4 F4 Gb4 A4  Bb4", "Gb4 A4"  ],
  ]
  include_examples "treble preset", "C", "min/maj7", false, 10, \
  [
    [ "C augmented", "C4 D#4 E4 G4 Ab4 B4" , "E4 G4 Ab4" ],
  ]
  include_examples "treble preset", "Db", "7#11", false, 9, \
  [
    [ "Db lydian dominant\n(4th degree of Ab mel min)", "Db4 Eb4 F4 G4 Ab4 Bb4 Cb4", "Eb4 Ab4"   ],
    [ "Db lydian dominant\n(4th degree of Ab mel min)", "Db4 Eb4 F4 G4 Ab4 Bb4 Cb4", "Eb4 Bb4"   ],
    [ "Db altered\n(7th degree of Ebb mel min)",  "Db4 Ebb4 Fb4 Gbb4 Abb4 Bbb4 Cb4", "Ebb4 Bbb4" ],
    [ "Db altered\n(7th degree of Ebb mel min)",  "Db4 Ebb4 Fb4 Gbb4 Abb4 Bbb4 Cb4", "Fb4 Bbb4"  ],
    [ "Db whole tone", "Db4 Eb4 F4 G4 A4 B4", "Eb4 A4" ],
    [ "6th degree of F diminished", "Db4 D4 E4 F4 G4 Ab4 Bb4 B4", "D4 Ab4" ],
    [ "6th degree of F diminished", "Db4 D4 E4 F4 G4 Ab4 Bb4 B4", "D4 Bb4" ],
    [ "6th degree of F diminished", "Db4 D4 E4 F4 G4 Ab4 Bb4 B4", "E4 Ab4" ],
    [ "6th degree of F diminished", "Db4 D4 E4 F4 G4 Ab4 Bb4 B4", "E4 Bb4" ],
  ]
  include_examples "treble preset", "Db", "7b9#9#11b13", true, 1, \
  [
    [ "Db altered\n(7th degree of Ebb mel min)",  "Db4 D4 E4 F4 G4 A4 B4", "" ],
  ]

  shared_examples "custom" do |key_name, descr, notes, simplify, exp_total, expected|
    fixed_chord_notes = notes.split.map { |n| Note[n] }
    include_examples "scalefinder", Note[key_name], descr, \
      fixed_chord_notes, 'treble', simplify, exp_total, expected
  end

  include_examples "custom", "C", "Ab/C", "C4 Eb4 Ab4", false, 15, \
  [
    [ "C phrygian\n(3rd degree of Ab maj)",              "C4 Db4 Eb4 F4 G4 Ab4 Bb4",   "Db4 F4 G4"      ],
    [ "C aeolian\n(6th degree of Eb maj)",               "C4 D4 Eb4 F4 G4 Ab4 Bb4",    "D4 G4 Bb4"      ],
    [ "C locrian\n(7th degree of Db maj)",               "C4 Db4 Eb4 F4 Gb4 Ab4 Bb4",  "Db4 F4 Gb4 Bb4" ],

    [ "C locrian natural 2\n(6th degree of Eb mel min)", "C4 D4 Eb4 F4 Gb4 Ab4 Bb4",   "D4 Gb4 Bb4"     ],
    [ "C altered\n(7th degree of Db mel min)",           "C4 Db4 Eb4 Fb4 Gb4 Ab4 Bb4", "Fb4 Gb4 Bb4"    ],

    [ "C harm min",                "C4 D4 Eb4 F4 G4 Ab4 B4",      "D4 G4 B4"      ],
    [ "C harm min",                "C4 D4 Eb4 F4 G4 Ab4 B4",      "F4 G4 B4"      ],
    [ "7th degree of Db harm min", "C4 Db4 Eb4 Fb4 Gb4 Ab4 Bbb4", "Db4 Fb4 Bbb4"  ],

    [ "3rd degree of Ab harm maj", "C4 Db4 Eb4 Fb4 G4 Ab4 Bb4",   "Db4 Fb4 G4"    ],
    [ "3rd degree of Ab harm maj", "C4 Db4 Eb4 Fb4 G4 Ab4 Bb4",   "Fb4 G4 Bb4"    ],
    [ "C lydian #2 #5\n(6th degree of E harm maj)",
                                   "C4 D#4 E4 F#4 G#4 A4 B4",     "E4 F#4 B4"     ],
    [ "C lydian #2 #5\n(6th degree of E harm maj)",
                                   "C4 D#4 E4 F#4 G#4 A4 B4",     "E4 A4 B4"      ],
    [ "7th degree of Db harm maj", "C4 Db4 Eb4 F4 Gb4 Ab4 Bbb4",  "Db4 F4 Bbb4"   ],

    [ "C diminished",              "C4 D4 Eb4 F4 Gb4 Ab4 A4 B4",  "D4 A4"         ],
    [ "C augmented",               "C4 D#4 E4 G4 Ab4 B4",         "E4 G4 B4"      ],
  ]

  context "correct positioning with alternate tonic" do
    include_examples "treble preset", "B", "min7", false, 12, \
    [
      [ "B dorian\n(2nd degree of A maj)", "B4 C#5 D5 E5 F#5 G#5 A5" , "C#5 E5 F#5 G#5" ],
    ]
  end

  context "correct positioning with alternate clefs" do
    include_examples "preset", "Db", "7b9#9#11b13", 'bass', false, true, 1, \
    [
      [ "Db altered\n(7th degree of Ebb mel min)",  "Db3 D3 E3 F3 G3 A3 B3", "" ],
    ]

    include_examples "preset", "D", "min11b5", 'bass', false, true, 2, \
    [
      [ "2nd degree of C harm maj",  "D3 E3 F3 G3 Ab3 B3 C4", "B3" ],
    ]

    include_examples "preset", "E", "min11b5", 'bass', false, true, 2, \
    [
      [ "2nd degree of D harm maj",  "E2 F#2 G2 A2 Bb2 C#3 D3", "C#3" ],
    ]

    include_examples "preset", "F", "min11b5", 'tenor', false, true, 2, \
    [
      [ "2nd degree of Eb harm maj",  "F3 G3 Ab3 Bb3 B3 D4 Eb4", "D4" ],
    ]
  end
end
