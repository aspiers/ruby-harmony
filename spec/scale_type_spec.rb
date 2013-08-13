require 'mode'
require 'scale_type'

describe ScaleType do
  it "should be prepopulated with the catalogue" do
    ScaleType.all.size.should == 7
  end

  describe "#degree_of" do
    [
      [ DiatonicScaleType::MAJOR,         'Bb', 'Bb', 1 ],
      [ DiatonicScaleType::MELODIC_MINOR, 'C',  'B',  7 ],
      [ SymmetricalScaleType::DIMINISHED, 'C',  'G#', 6 ],
    ].each do |scale_type, key_name, note_name, expected_degree|
      context "#{key_name} #{scale_type}" do
        it "should return the right degree for #{note_name}" do
          scale_type.degree_of(Note[note_name], Note[key_name]).should == expected_degree
        end
      end
    end
  end
end

describe DiatonicScaleType do
  it "should be prepopulated with 4 types" do
    DiatonicScaleType.all_in_subclass.size.should == 4
  end

  describe "#symmetrical?" do
    DiatonicScaleType.all_in_subclass.each do |type|
      context type do
        it "should not be symmetrical by mode" do
          type.symmetrical_modes?.should be_false
        end

        it "should not be symmetrical by transposition" do
          type.symmetrical_keys?.should be_false
        end
      end
    end
  end

  shared_examples "a diatonic scale" do |scale, tests|
    tests.each do |name, degree, key_name|
      note = Note.by_name(name)
      it "should have the right key (#{key_name}) when #{note} is degree #{degree}" do
        k, d = scale.key_and_degree(note, degree)
        k.name.should == key_name
        degree.should == d
      end

      specify "degree #{degree} of #{key_name} is #{name}" do
        key_note = Note.by_name(key_name)
        scale.note(key_note, degree).name.should == name
      end
    end
  end

  context "major scales" do
    it_should_behave_like "a diatonic scale", DiatonicScaleType::MAJOR, [
      [ "C",   1, "C"  ],
      [ "D",   2, "C"  ],
      [ "E",   3, "C"  ],
      [ "A",   6, "C"  ],
      [ "B",   7, "C"  ],

      # flats
      [ "Ab",  1, "Ab" ],
      [ "Bb",  2, "Ab" ],
      [ "C",   3, "Ab" ],
      [ "F",   6, "Ab" ],
      [ "G",   7, "Ab" ],

      [ "Cb",  1, "Cb" ],
      [ "Db",  2, "Cb" ],
      [ "Eb",  3, "Cb" ],
      [ "Ab",  6, "Cb" ],
      [ "Bb",  7, "Cb" ],

      # sharps
      [ "A",   1, "A"  ],
      [ "B",   2, "A"  ],
      [ "C#",  3, "A"  ],
      [ "F#",  6, "A"  ],
      [ "G#",  7, "A"  ],

      [ "B",   1, "B"  ],
      [ "C#",  2, "B"  ],
      [ "D#",  3, "B"  ],
      [ "G#",  6, "B"  ],
      [ "A#",  7, "B"  ],
    ]
  end

  context "melodic minor scales" do
    it_should_behave_like "a diatonic scale", DiatonicScaleType::MELODIC_MINOR, [
      [ "C",   1, "C"  ],
      [ "D",   2, "C"  ],
      [ "Eb",  3, "C"  ],
      [ "A",   6, "C"  ],
      [ "B",   7, "C"  ],

      # flats
      [ "Ab",  1, "Ab" ],
      [ "Bb",  2, "Ab" ],
      [ "Cb",  3, "Ab" ],
      [ "F",   6, "Ab" ],
      [ "G",   7, "Ab" ],

      [ "Cb",  1, "Cb" ],
      [ "Db",  2, "Cb" ],
      [ "Ebb", 3, "Cb" ],
      [ "Ab",  6, "Cb" ],
      [ "Bb",  7, "Cb" ],

      # sharps
      [ "A",  1, "A"  ],
      [ "B",  2, "A"  ],
      [ "C",  3, "A"  ],
      [ "F#", 6, "A"  ],
      [ "G#", 7, "A"  ],

      [ "B",  1, "B"  ],
      [ "C#", 2, "B"  ],
      [ "D",  3, "B"  ],
      [ "G#", 6, "B"  ],
      [ "A#", 7, "B"  ],
    ]
  end

  context "harmonic minor scales" do
    it_should_behave_like "a diatonic scale", DiatonicScaleType::HARMONIC_MINOR, [
      [ "C",  1, "C" ],
      [ "D",  2, "C" ],
      [ "Eb", 3, "C" ],
      [ "Ab", 6, "C" ],
      [ "B",  7, "C" ],

      # flats
      [ "Ab", 1, "Ab" ],
      [ "Bb", 2, "Ab" ],
      [ "Cb", 3, "Ab" ],
      [ "Fb", 6, "Ab" ],
      [ "G",  7, "Ab" ],

      # sharps
      [ "A",  1, "A"  ],
      [ "B",  2, "A"  ],
      [ "C",  3, "A"  ],
      [ "F",  6, "A"  ],
      [ "G#", 7, "A"  ],

      [ "B",  1, "B"  ],
      [ "C#", 2, "B"  ],
      [ "D",  3, "B"  ],
      [ "G",  6, "B"  ],
      [ "A#", 7, "B"  ],
    ]
  end

  context "harmonic major scales" do
    it_should_behave_like "a diatonic scale", DiatonicScaleType::HARMONIC_MAJOR, [
      [ "C",  1, "C" ],
      [ "D",  2, "C" ],
      [ "E",  3, "C" ],
      [ "Ab", 6, "C" ],
      [ "B",  7, "C" ],

      # flats
      [ "Ab", 1, "Ab" ],
      [ "Bb", 2, "Ab" ],
      [ "C",  3, "Ab" ],
      [ "Fb", 6, "Ab" ],
      [ "G",  7, "Ab" ],

      # sharps
      [ "A",  1, "A"  ],
      [ "B",  2, "A"  ],
      [ "C#", 3, "A"  ],
      [ "F",  6, "A"  ],
      [ "G#", 7, "A"  ],

      [ "B",  1, "B"  ],
      [ "C#", 2, "B"  ],
      [ "D#", 3, "B"  ],
      [ "G",  6, "B"  ],
      [ "A#", 7, "B"  ],
    ]
  end

  context "#offset_from_key" do
    specify "major should return a major third" do
      DiatonicScaleType::MAJOR.offset_from_key(3).should == 4
    end

    specify "major should return a major tenth" do
      DiatonicScaleType::MAJOR.offset_from_key(10).should == 16
    end

    specify "harmonic major should return a major third" do
      DiatonicScaleType::HARMONIC_MAJOR.offset_from_key(3).should == 4
    end

    specify "harmonic major should return a b13" do
      DiatonicScaleType::HARMONIC_MAJOR.offset_from_key(13).should == 20
    end

    specify "melodic minor should return a minor third" do
      DiatonicScaleType::MELODIC_MINOR.offset_from_key(3).should == 3
    end

    specify "melodic minor should return a natural 11" do
      DiatonicScaleType::MELODIC_MINOR.offset_from_key(11).should == 17
    end

    specify "harmonic minor should return a minor third" do
      DiatonicScaleType::HARMONIC_MINOR.offset_from_key(3).should == 3
    end
  end
end

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
        include_examples "equivalent keys", scale_type,
          key_name, pitches, notes.split
      end
    end
  end

  describe SymmetricalScaleType::DIMINISHED do
    # annoyingly necessary, presumably because it's an instance not a class
    subject { SymmetricalScaleType::DIMINISHED }

    shared_examples "good key" do |starting_note, degree, expected|
      it "should choose a good key for #{starting_note} degree #{degree}" do
        mode = Mode.new(degree, subject, -1)
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
