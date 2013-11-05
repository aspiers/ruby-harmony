require 'note'
require 'mode'
require 'symmetrical_scale_type'

describe SymmetricalScaleType do
  it "should be prepopulated with 2 types" do
    SymmetricalScaleType.all_in_subclass.size.should == 3
  end

  describe "symmetrical?" do
    SymmetricalScaleType.all_in_subclass.each do |type|
      context type do
        it "should be symmetrical by mode" do
          type.symmetrical_modes?.should be_true
        end

        it "should be symmetrical by transposition" do
          type.symmetrical_keys?.should be_true
        end
      end
    end
  end

  describe "#equivalent_keys" do
    shared_examples "equivalent keys" do |scale_type, key_name, pitches, notes|
      specify "#{scale_type} equivalent pitches of #{key_name} should be right" do
        key_note = Note.by_name(key_name)
        scale_type.equivalent_key_pitches(key_note).should == pitches
      end

      specify "#{scale_type} equivalent notes of #{key_name} should be right" do
        key_note = Note.by_name(key_name)
        scale_type.equivalent_keys(key_note).map(&:name).should == notes
      end
    end

    [
      [
        SymmetricalScaleType::DIMINISHED,
        [
          [ 'C',  [ 0, 3,  6,  9 ], 'C  D# Eb F# Gb A'  ],
          [ 'C#', [ 1, 4,  7, 10 ], 'C# Db E  G  A# Bb' ],
          [ 'Db', [ 1, 4,  7, 10 ], 'C# Db E  G  A# Bb' ],
          [ 'D',  [ 2, 5,  8, 11 ], 'D  F  G# Ab B'     ],
          [ 'D#', [ 3, 6,  9, 12 ], 'D# Eb F# Gb A  C'  ],
          [ 'E',  [ 4, 7, 10, 13 ], 'E  G  A# Bb C# Db' ],
        ]
      ],
      [
        SymmetricalScaleType::WHOLE_TONE,
        [
          [ 'C',  [ 0, 2, 4, 6, 8, 10 ], 'C D E F# Gb G# Ab A# Bb'  ],
        ]
      ]
    ].each do |scale_type, rest|
      rest.each do |key_name, pitches, notes|
        include_examples "equivalent keys", scale_type, \
          key_name, pitches.map { |p| p + 60 }, notes.split
      end
    end
  end

  describe SymmetricalScaleType::DIMINISHED do
    # annoyingly necessary, presumably because it's an instance not a class
    subject { SymmetricalScaleType::DIMINISHED }

    shared_examples "good key" do |starting_note, degree, expected|
      it "should choose a good key for #{starting_note} degree #{degree}" do
        mode = Mode.new(degree, subject)
        k, d = subject.key_and_degree(Note[starting_note], mode.degree)
        k.name.should == expected
      end
    end

    [
      [ 'C',  'C',  'G'  ],
      [ 'C#', 'E',  'B'  ],
      [ 'Db', 'G',  'F'  ],
      [ 'D',  'D',  'C'  ],
      [ 'D#', 'D#', 'E'  ],
      [ 'Eb', 'Eb', 'G'  ],
      [ 'E',  'E',  'D'  ],
    ].each do |starting_note, expected_primary_key, expected_aux_key|
      include_examples "good key", starting_note, 1, expected_primary_key
      include_examples "good key", starting_note, 2, expected_aux_key
    end
  end
end
