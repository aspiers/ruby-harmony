require 'scale_type'

describe DiatonicScaleType do
  shared_examples "a diatonic scale" do |scale, tests|
    tests.each do |name, degree, key_name|
      note = Note.by_name(name)
      it "should have the right key (#{key_name}) when #{note} is degree #{degree}" do
        scale.key(note, degree).name.should == key_name
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
