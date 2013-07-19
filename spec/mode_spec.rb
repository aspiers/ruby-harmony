require 'mode'

describe Mode do
  it "should have the right increments" do
    Mode.new(1, DiatonicScale::MAJOR, -1).increments.should == [ 2, 2, 1, 2, 2, 2 ]
    Mode.new(2, DiatonicScale::MAJOR, -1).increments.should == [ 2, 1, 2, 2, 2, 1 ]
    Mode.new(7, DiatonicScale::MAJOR, -1).increments.should == [ 1, 2, 2, 1, 2, 2 ]

    Mode.new(1, DiatonicScale::HARMONIC_MINOR, -1).increments.should == [ 2, 1, 2, 2, 1, 3 ]
    Mode.new(2, DiatonicScale::HARMONIC_MINOR, -1).increments.should == [ 1, 2, 2, 1, 3, 1 ]
  end

  it "should have the right degrees" do
    Mode.new(1, DiatonicScale::MAJOR, -1).degrees.should == [ 1, 2, 3, 4, 5, 6, 7 ]
    Mode.new(2, DiatonicScale::MAJOR, -1).degrees.should == [ 2, 3, 4, 5, 6, 7, 1 ]
  end

  shared_examples "contains notes given key" do |scale, degree, key_name, expected_notes|
    it "should have the right notes" do
      key_note = Note.by_name(key_name)
      mode = Mode.new(degree, scale, -1)
      notes = mode.notes(key_note)
      notes.map { |n| n.name }.should == expected_notes
    end
  end

  it_should_behave_like "contains notes given key", DiatonicScale::MAJOR, \
    1, "A", "A B C# D E F# G#".split

  it_should_behave_like "contains notes given key", DiatonicScale::MELODIC_MINOR, \
    2, "B", "C# D E F# G# A# B".split

  it_should_behave_like "contains notes given key", DiatonicScale::HARMONIC_MINOR, \
    2, "B", "C# D E F# G A# B".split

  it_should_behave_like "contains notes given key", DiatonicScale::HARMONIC_MAJOR, \
    7, "F", "E F G A Bb C Db".split

  shared_examples "notes in mode given starting note" do |scale, degree, start_name, expected_notes|
    it "should have the right notes" do
      start_note = Note.by_name(start_name)
      mode = Mode.new(degree, scale, -1)
      notes = mode.notes_from(start_note)
      notes.map { |n| n.name }.should == expected_notes
    end
  end

  include_examples "notes in mode given starting note", DiatonicScale::MAJOR, \
    1, "Eb", "Eb F G Ab Bb C D".split

  include_examples "notes in mode given starting note", DiatonicScale::MELODIC_MINOR, \
    3, "Eb", "Eb F G A B C D".split

  include_examples "notes in mode given starting note", DiatonicScale::HARMONIC_MINOR, \
    7, "D", "D Eb F Gb Ab Bb Cb".split

  include_examples "notes in mode given starting note", DiatonicScale::HARMONIC_MAJOR, \
    3, "E#", "E# F# G# A B# C# D#".split
end

describe ScaleType do
  it "should be prepopulated with the standard modes" do
    ScaleType.all.size.should == 4
  end
end
