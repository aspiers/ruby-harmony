require 'scale_finder'
require 'chord_type'
require 'mode_in_key'
require 'note'

describe ScaleFinder do
  shared_examples "scalefinder" do
    |key, descr, fixed_chord_notes, simplify, exp_total, expected|

    context "finds #{simplify ? 'simplified ' : ''}scales including: #{fixed_chord_notes.join(' ')}" do
      let(:scalefinder) { ScaleFinder.new(fixed_chord_notes, key.name, descr) }
      before {
        scalefinder.set_verbosity(0)
        scalefinder.enable_simplification if simplify
        scales = ModeInKey.all(key).flatten
        scalefinder.identify_modes
      }

      it "should find the right number of scales" do
        scalefinder.scales.size.should == exp_total
      end

      it "should find the right scales and identifiers" do
        results = scalefinder.scales.map do |scale, notes, chord|
          [ scale.name, notes.join(' '), chord.join(' ') ]
        end
        expected.each do |ename, enotes, eidents|
          results.should include([ ename, enotes.split.join(' '), eidents.split.join(' ') ])
        end
      end
    end
  end

  shared_examples "preset" do |key_name, chord_type, simplify, exp_total, expected|
    key = Note[key_name]
    fixed_chord_notes = ChordType[chord_type].notes(key)
    include_examples "scalefinder",
      key, key_name + chord_type, fixed_chord_notes, simplify, exp_total, expected
  end

  include_examples "preset", "C", "7b9", false, 7, \
  [
    [ "C altered\n(7th degree of Db mel min)",
                                    "C Db Eb Fb Gb Ab Bb", "Gb Ab"   ],
    [ "C dominant b9 b13\n(5th degree of F harm min)",
                                    "C Db E F G Ab Bb"   , "F Ab"    ],
    [ "3rd degree of Ab harm maj",  "C Db Eb Fb G Ab Bb" , "Eb G Ab" ],
    [ "C dominant b9\n(5th degree of F harm maj)",
                                    "C Db E F G A Bb"    , "F A"     ],
    [ "4th degree of G diminished", "C Db Eb E F# G A Bb", "Eb A"    ],
    [ "4th degree of G diminished", "C Db Eb E F# G A Bb", "F# G"    ],
    # Don't need this since partial expectations are allowed.
    #[ "4th degree of G diminished", "C Db Eb E F# G A Bb", "F# A"    ],
  ]
  include_examples "preset", "C", "min11", false, 4, \
  [
    [ "C dorian\n(2nd degree of Bb maj)",  "C D Eb F G  A Bb" , "G  A"  ],
    [ "C aeolian\n(6th degree of Eb maj)", "C D Eb F G  Ab Bb", "G  Ab" ],
    [ "C locrian natural 2\n(6th degree of Eb mel min)",
                                           "C D Eb F Gb Ab Bb", "Gb Ab" ],
    [ "2nd degree of Bb harm maj",         "C D Eb F Gb A  Bb", "Gb A"  ],
  ]
  include_examples "preset", "C", "min/maj7", false, 10, \
  [
    [ "C augmented", "C D# E G Ab B" , "E G Ab" ],
  ]
  include_examples "preset", "Db", "7#11", false, 9, \
  [
    [ "Db lydian dominant\n(4th degree of Ab mel min)", "Db Eb F G Ab Bb Cb", "Eb Ab"   ],
    [ "Db lydian dominant\n(4th degree of Ab mel min)", "Db Eb F G Ab Bb Cb", "Eb Bb"   ],
    [ "Db altered\n(7th degree of Ebb mel min)",  "Db Ebb Fb Gbb Abb Bbb Cb", "Ebb Bbb" ],
    [ "Db altered\n(7th degree of Ebb mel min)",  "Db Ebb Fb Gbb Abb Bbb Cb", "Fb Bbb"  ],
    [ "Db whole tone", "Db Eb F G A B", "Eb A" ],
    [ "6th degree of F diminished", "Db D E F G Ab Bb B", "D Ab" ],
    [ "6th degree of F diminished", "Db D E F G Ab Bb B", "D Bb" ],
    [ "6th degree of F diminished", "Db D E F G Ab Bb B", "E Ab" ],
    [ "6th degree of F diminished", "Db D E F G Ab Bb B", "E Bb" ],
  ]
  include_examples "preset", "Db", "7b9#9#11b13", true, 1, \
  [
    [ "Db altered\n(7th degree of Ebb mel min)",  "Db D E F G A B", "" ],
  ]

  shared_examples "custom" do |key_name, descr, notes, simplify, exp_total, expected|
    fixed_chord_notes = notes.split.map { |n| Note[n] }
    include_examples "scalefinder", Note[key_name], descr, \
      fixed_chord_notes, simplify, exp_total, expected
  end

  include_examples "custom", "C", "Ab/C", "C Eb Ab", false, 15, \
  [
    [ "C phrygian\n(3rd degree of Ab maj)",              "C Db Eb F G Ab Bb",    "Db F G"     ],
    [ "C aeolian\n(6th degree of Eb maj)",               "C D Eb F G Ab Bb",     "D G Bb"     ],
    [ "C locrian\n(7th degree of Db maj)",               "C Db Eb F Gb Ab Bb",   "Db F Gb Bb" ],

    [ "C locrian natural 2\n(6th degree of Eb mel min)", "C D Eb F Gb Ab Bb",    "D Gb Bb"    ],
    [ "C altered\n(7th degree of Db mel min)",           "C Db Eb Fb Gb Ab Bb",  "Fb Gb Bb"   ],

    [ "C harm min",                "C D Eb F G Ab B",      "D G B"      ],
    [ "C harm min",                "C D Eb F G Ab B",      "F G B"      ],
    [ "7th degree of Db harm min", "C Db Eb Fb Gb Ab Bbb", "Db Fb Bbb"  ],

    [ "3rd degree of Ab harm maj", "C Db Eb Fb G Ab Bb",   "Db Fb G"    ],
    [ "3rd degree of Ab harm maj", "C Db Eb Fb G Ab Bb",   "Fb G Bb"    ],
    [ "C lydian #2 #5\n(6th degree of E harm maj)",
                                   "C D# E F# G# A B",     "E F# B"     ],
    [ "C lydian #2 #5\n(6th degree of E harm maj)",
                                   "C D# E F# G# A B",     "E A B"      ],
    [ "7th degree of Db harm maj", "C Db Eb F Gb Ab Bbb",  "Db F Bbb"   ],

    [ "C diminished",              "C D Eb F Gb Ab A B",   "D A"        ],
    [ "C augmented",               "C D# E G Ab B",        "E G B"      ],
  ]
end
