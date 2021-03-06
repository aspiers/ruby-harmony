# -*- coding: utf-8 -*-

require 'mode'

describe Mode do
  it "should have the right increments" do
    Mode.new(1, DiatonicScaleType::MAJOR).increments.should == [ 2, 2, 1, 2, 2, 2 ]
    Mode.new(2, DiatonicScaleType::MAJOR).increments.should == [ 2, 1, 2, 2, 2, 1 ]
    Mode.new(7, DiatonicScaleType::MAJOR).increments.should == [ 1, 2, 2, 1, 2, 2 ]

    Mode.new(1, DiatonicScaleType::HARMONIC_MINOR).increments.should == [ 2, 1, 2, 2, 1, 3 ]
    Mode.new(2, DiatonicScaleType::HARMONIC_MINOR).increments.should == [ 1, 2, 2, 1, 3, 1 ]
  end

  it "should have the right degrees" do
    Mode.new(1, DiatonicScaleType::MAJOR).degrees.should == [ 1, 2, 3, 4, 5, 6, 7 ]
    Mode.new(2, DiatonicScaleType::MAJOR).degrees.should == [ 2, 3, 4, 5, 6, 7, 1 ]
  end

  shared_examples "given key" do |scale, degree, key_name, expected_name, expected_notes|
    context "degree #{degree} of #{key_name} #{scale}" do
      let(:mode) { Mode.new(degree, scale) }

      it "should have the right name" do
        mode.to_s.should == expected_name
      end

      it "should have the right notes" do
        key_note = Note.by_name(key_name)
        notes = mode.notes(key_note)
        notes.map { |n| n.name }.should == expected_notes
      end
    end
  end

  include_examples "given key", DiatonicScaleType::MAJOR, \
    1, "A", "ionian", "A B C# D E F# G#".split

  include_examples "given key", DiatonicScaleType::MELODIC_MINOR, \
    2, "B", "dorian b9", "C# D E F# G# A# B".split

  include_examples "given key", DiatonicScaleType::MELODIC_MINOR, \
    6, "D", "locrian ♮9", "B C# D E F G A".split

  include_examples "given key", DiatonicScaleType::MELODIC_MINOR, \
    7, "C", "altered", "B C D Eb F G A".split

  include_examples "given key", DiatonicScaleType::HARMONIC_MINOR, \
    2, "B", "locrian ♮6", "C# D E F# G A# B".split

  include_examples "given key", DiatonicScaleType::HARMONIC_MAJOR, \
    7, "F", "locrian bb7", "E F G A Bb C Db".split

  shared_examples "given starting note" do
    |scale, degree, start_name, expected_notes, expected_name|

    context "degree #{degree} of #{scale} starting on #{start_name}" do
      let(:start_note) { Note.by_name(start_name)    }
      let(:mode)       { Mode.new(degree, scale) }

      it "should have the right name" do
        mode.to_s.should == expected_name
      end

      it "should have the right notes" do
        notes = mode.notes_from(start_note)
        notes.map { |n| n.name }.should == expected_notes.split
      end
    end
  end

  describe "diatonic" do
    include_examples "given starting note", DiatonicScaleType::MAJOR, \
      1, "Eb", "Eb F  G  Ab Bb C  D",  "ionian"
    include_examples "given starting note", DiatonicScaleType::MELODIC_MINOR, \
      3, "Eb", "Eb F  G  A  B  C  D",  "lydian augmented"
    include_examples "given starting note", DiatonicScaleType::HARMONIC_MINOR, \
      7, "D",  "D  Eb F  Gb Ab Bb Cb", "altered bb7"
    include_examples "given starting note", DiatonicScaleType::HARMONIC_MAJOR, \
      3, "E#", "E# F# G# A  B# C# D#", "altered ♮5"
  end

  describe "diminished" do
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      1, "C",  "C D Eb F Gb Ab A B",  nil
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      2, "C",  "C Db Eb E F# G A Bb", "auxiliary diminished"
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      1, "C#", "C# D# E F# G A Bb C", nil
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      2, "C#", "C# D E F G G# A# B",  "auxiliary diminished"
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      1, "Db", "Db Eb E F# G A Bb C", nil
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      2, "Db", "Db D E F G Ab Bb B",  "auxiliary diminished"
  end

  describe "whole tone" do
    include_examples "given starting note", SymmetricalScaleType::WHOLE_TONE, \
      1, "C",  "C D E F# G# A#", "whole tone"
    include_examples "given starting note", SymmetricalScaleType::WHOLE_TONE, \
      1, "C#", "C# D# F G A B",  "whole tone"
    include_examples "given starting note", SymmetricalScaleType::WHOLE_TONE, \
      1, "Db", "Db Eb F G A B",  "whole tone"
    include_examples "given starting note", SymmetricalScaleType::WHOLE_TONE, \
      1, "D",  "D E F# G# A# C", "whole tone"
  end

  describe "#best_display_key_and_mode" do
    [
      [ DiatonicScaleType::MAJOR,         'C', 2, 'Bb', 2 ],
      [ SymmetricalScaleType::DIMINISHED, 'C', 2, 'G',  4 ],
    ].each do |scale_type, starting_note, degree, best_key, best_degree|
      context "degree #{degree} of #{scale_type} as #{starting_note}" do
        let(:mode) { Mode.new(degree, scale_type) }

        it "should return the right key and mode" do
          key_note, display_mode = mode.best_display_key_and_mode(Note[starting_note])
          key_note.name.should == best_key
          display_mode.degree.should == best_degree
        end
      end
    end
  end

  describe "name overriding" do
    it "should allow the name to be overridden" do
      mode = Mode.new(3, DiatonicScaleType::HARMONIC_MAJOR)
      new_name = 'new name'
      mode.name!(new_name)
      mode.name.should == new_name
    end
  end
end
