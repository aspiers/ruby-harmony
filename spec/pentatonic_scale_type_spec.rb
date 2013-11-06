require 'note'
require 'pentatonic_scale_type'

describe PentatonicScaleType do
  it "should be prepopulated with 2 types" do
    PentatonicScaleType.all_in_subclass.size.should == 5
  end

  describe "#symmetrical?" do
    PentatonicScaleType.all_in_subclass.each do |type|
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

  shared_examples "a pentatonic scale" do |scale, tests|
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

  context "major pentatonic" do
    it_should_behave_like "a pentatonic scale", PentatonicScaleType::MAJOR, [
      [ "C",   1, "C"  ],
      [ "D",   2, "C"  ],
      [ "E",   3, "C"  ],
      [ "G",   4, "C"  ],
      [ "A",   5, "C"  ],

      # flats
      [ "Ab",  1, "Ab" ],
      [ "Bb",  2, "Ab" ],
      [ "C",   3, "Ab" ],
      [ "Eb",  4, "Ab" ],
      [ "F",   5, "Ab" ],

      [ "Cb",  1, "Cb" ],
      [ "Db",  2, "Cb" ],
      [ "Eb",  3, "Cb" ],
      [ "Gb",  4, "Cb" ],
      [ "Ab",  5, "Cb" ],

      # sharps
      [ "A",   1, "A"  ],
      [ "B",   2, "A"  ],
      [ "C#",  3, "A"  ],
      [ "E",   4, "A"  ],
      [ "F#",  5, "A"  ],

      [ "B",   1, "B"  ],
      [ "C#",  2, "B"  ],
      [ "D#",  3, "B"  ],
      [ "F#",  4, "B"  ],
      [ "G#",  5, "B"  ],
    ]
  end

  context "minor 6 pentatonic" do
    it_should_behave_like "a pentatonic scale", PentatonicScaleType::MINOR_SIX, [
      [ "C",   1, "C"  ],
      [ "D",   2, "C"  ],
      [ "Eb",  3, "C"  ],
      [ "G",   4, "C"  ],
      [ "A",   5, "C"  ],

      # flats
      [ "Ab",  1, "Ab" ],
      [ "Bb",  2, "Ab" ],
      [ "Cb",  3, "Ab" ],
      [ "Eb",  4, "Ab" ],
      [ "F",   5, "Ab" ],

      [ "Cb",  1, "Cb" ],
      [ "Db",  2, "Cb" ],
      [ "Ebb", 3, "Cb" ],
      [ "Gb",  4, "Cb" ],
      [ "Ab",  5, "Cb" ],

      # sharps
      [ "A",   1, "A"  ],
      [ "B",   2, "A"  ],
      [ "C",   3, "A"  ],
      [ "E",   4, "A"  ],
      [ "F#",  5, "A"  ],

      [ "B",   1, "B"  ],
      [ "C#",  2, "B"  ],
      [ "D",   3, "B"  ],
      [ "F#",  4, "B"  ],
      [ "G#",  5, "B"  ],
    ]
  end

  context "major b2 pentatonic" do
    it_should_behave_like "a pentatonic scale", PentatonicScaleType::FLAT_TWO, [
      [ "C",   1, "C"  ],
      [ "Db",   2, "C"  ],
      [ "E",   3, "C"  ],
      [ "G",   4, "C"  ],
      [ "A",   5, "C"  ],

      # flats
      [ "Ab",  1, "Ab" ],
      [ "Bbb", 2, "Ab" ],
      [ "C",   3, "Ab" ],
      [ "Eb",  4, "Ab" ],
      [ "F",   5, "Ab" ],

      [ "Cb",  1, "Cb" ],
      [ "Dbb", 2, "Cb" ],
      [ "Eb",  3, "Cb" ],
      [ "Gb",  4, "Cb" ],
      [ "Ab",  5, "Cb" ],

      # sharps
      [ "A",   1, "A"  ],
      [ "Bb",  2, "A"  ],
      [ "C#",  3, "A"  ],
      [ "E",   4, "A"  ],
      [ "F#",  5, "A"  ],

      [ "B",   1, "B"  ],
      [ "C",   2, "B"  ],
      [ "D#",  3, "B"  ],
      [ "F#",  4, "B"  ],
      [ "G#",  5, "B"  ],
    ]
  end

  context "major b6 pentatonic" do
    it_should_behave_like "a pentatonic scale", PentatonicScaleType::FLAT_SIX, [
      [ "C",   1, "C"  ],
      [ "D",   2, "C"  ],
      [ "E",   3, "C"  ],
      [ "G",   4, "C"  ],
      [ "Ab",  5, "C"  ],

      # flats
      [ "Ab",  1, "Ab" ],
      [ "Bb",  2, "Ab" ],
      [ "C",   3, "Ab" ],
      [ "Eb",  4, "Ab" ],
      [ "Fb",  5, "Ab" ],

      [ "Cb",  1, "Cb" ],
      [ "Db",  2, "Cb" ],
      [ "Eb",  3, "Cb" ],
      [ "Gb",  4, "Cb" ],
      [ "Abb", 5, "Cb" ],

      # sharps
      [ "A",   1, "A"  ],
      [ "B",   2, "A"  ],
      [ "C#",  3, "A"  ],
      [ "E",   4, "A"  ],
      [ "F",   5, "A"  ],

      [ "B",   1, "B"  ],
      [ "C#",  2, "B"  ],
      [ "D#",  3, "B"  ],
      [ "F#",  4, "B"  ],
      [ "G",   5, "B"  ],
    ]
  end

  context "whole tone pentatonic" do
    it_should_behave_like "a pentatonic scale", PentatonicScaleType::WHOLE_TONE, [
      [ "C",   1, "C"  ],
      [ "E",   2, "C"  ],
      [ "F#",  3, "C"  ],
      [ "Ab",  4, "C"  ],
      [ "Bb",  5, "C"  ],

      # flats
      [ "Ab",  1, "Ab" ],
      [ "C",   2, "Ab" ],
      [ "D",   3, "Ab" ],
      [ "Fb",  4, "Ab" ],
      [ "Gb",  5, "Ab" ],

      [ "Cb",  1, "Cb" ],
      [ "Eb",  2, "Cb" ],
      [ "F",   3, "Cb" ],
      [ "Abb", 4, "Cb" ],
      [ "Bbb", 5, "Cb" ],

      # sharps
      [ "A",   1, "A"  ],
      [ "C#",  2, "A"  ],
      [ "D#",  3, "A"  ],
      [ "F",   4, "A"  ],
      [ "G",   5, "A"  ],

      [ "B",   1, "B"  ],
      [ "D#",  2, "B"  ],
      [ "E#",  3, "B"  ],
      [ "G",   4, "B"  ],
      [ "A",   5, "B"  ],
    ]
  end

  context "#offset_from_key" do
    specify "major should return a major third" do
      PentatonicScaleType::MAJOR.offset_from_key(3).should == 4
    end

    specify "major should return a major tenth" do
      PentatonicScaleType::MAJOR.offset_from_key(8).should == 16
    end
  end
end

