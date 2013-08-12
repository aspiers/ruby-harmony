require 'mode'

describe Mode do
  it "should have the right increments" do
    Mode.new(1, DiatonicScaleType::MAJOR, -1).increments.should == [ 2, 2, 1, 2, 2, 2 ]
    Mode.new(2, DiatonicScaleType::MAJOR, -1).increments.should == [ 2, 1, 2, 2, 2, 1 ]
    Mode.new(7, DiatonicScaleType::MAJOR, -1).increments.should == [ 1, 2, 2, 1, 2, 2 ]

    Mode.new(1, DiatonicScaleType::HARMONIC_MINOR, -1).increments.should == [ 2, 1, 2, 2, 1, 3 ]
    Mode.new(2, DiatonicScaleType::HARMONIC_MINOR, -1).increments.should == [ 1, 2, 2, 1, 3, 1 ]
  end

  it "should have the right degrees" do
    Mode.new(1, DiatonicScaleType::MAJOR, -1).degrees.should == [ 1, 2, 3, 4, 5, 6, 7 ]
    Mode.new(2, DiatonicScaleType::MAJOR, -1).degrees.should == [ 2, 3, 4, 5, 6, 7, 1 ]
  end

  shared_examples "given key" do |scale, degree, key_name, expected_name, expected_notes|
    it "should have the right name" do
      mode = Mode.new(degree, scale, -1)
      mode.to_s.should == expected_name
    end

    it "should have the right notes" do
      key_note = Note.by_name(key_name)
      mode = Mode.new(degree, scale, -1)
      notes = mode.notes(key_note)
      notes.map { |n| n.name }.should == expected_notes
    end
  end

  include_examples "given key", DiatonicScaleType::MAJOR, \
    1, "A", "ionian", "A B C# D E F# G#".split

  include_examples "given key", DiatonicScaleType::MELODIC_MINOR, \
    2, "B", nil, "C# D E F# G# A# B".split

  include_examples "given key", DiatonicScaleType::MELODIC_MINOR, \
    6, "D", "locrian natural 2", "B C# D E F G A".split

  include_examples "given key", DiatonicScaleType::MELODIC_MINOR, \
    7, "C", "altered", "B C D Eb F G A".split

  include_examples "given key", DiatonicScaleType::HARMONIC_MINOR, \
    2, "B", nil, "C# D E F# G A# B".split

  include_examples "given key", DiatonicScaleType::HARMONIC_MAJOR, \
    7, "F", nil, "E F G A Bb C Db".split

  shared_examples "given starting note" do |scale, degree, start_name, expected_notes|
    specify "degree #{degree} starting on #{start_name} should have the right notes" do
      start_note = Note.by_name(start_name)
      mode = Mode.new(degree, scale, -1)
      notes = mode.notes_from(start_note)
      notes.map { |n| n.name }.should == expected_notes
    end
  end

  describe "diatonic" do
    include_examples "given starting note", DiatonicScaleType::MAJOR, \
      1, "Eb", "Eb F G Ab Bb C D".split
    include_examples "given starting note", DiatonicScaleType::MELODIC_MINOR, \
      3, "Eb", "Eb F G A B C D".split
    include_examples "given starting note", DiatonicScaleType::HARMONIC_MINOR, \
      7, "D",  "D Eb F Gb Ab Bb Cb".split
    include_examples "given starting note", DiatonicScaleType::HARMONIC_MAJOR, \
      3, "E#", "E# F# G# A B# C# D#".split
  end

  describe "diminished" do
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      1, "C",  "C D Eb F Gb Ab A B".split
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      2, "C",  "C Db Eb E F# G A Bb".split
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      1, "C#", "C# D# E F# G A Bb C".split
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      2, "C#", "C# D E F G G# A# B".split
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      1, "Db", "Db Eb E F# G A Bb C".split
    include_examples "given starting note", SymmetricalScaleType::DIMINISHED, \
      2, "Db", "Db D E F G Ab Bb B".split
  end

  describe "whole tone", broken: true do
    include_examples "given starting note", SymmetricalScaleType::WHOLE_TONE, \
      1, "C", "C D E F# G# A#".split
    include_examples "given starting note", SymmetricalScaleType::WHOLE_TONE, \
      1, "C#", "C# D# F G A B".split
    include_examples "given starting note", SymmetricalScaleType::WHOLE_TONE, \
      1, "Db", "Db Eb F G A B".split
    include_examples "given starting note", SymmetricalScaleType::WHOLE_TONE, \
      1, "D",  "D E F# G# A# C".split
  end
end
