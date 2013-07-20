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

describe ModeInKey do
  it "should have the right notes" do
    mode = Mode.new(6, DiatonicScale::HARMONIC_MAJOR, -1)
    key_note = Note.by_name("E")
    mode_in_key = ModeInKey.new(mode, key_note)
    mode_in_key.notes.map { |n| n.to_s }.should == \
      %w(C D# E F# G# A B)
  end

  shared_examples "counting accidentals" do |degree, scale_type, key_name, sharps, flats|
    mode = Mode.new(degree, scale_type, -1)
    key_note = Note.by_name(key_name)
    mode_in_key = ModeInKey.new(mode, key_note)

    it "#{mode_in_key} should have the right number of sharps (#{sharps})" do
      mode_in_key.num_sharps.should == sharps
    end

    it "#{mode_in_key} should have the right number of flats (#{flats})" do
      mode_in_key.num_flats.should == flats
    end

    it "#{mode_in_key} should have the right accidental count pair" do
      mode_in_key.accidentals.should == [ sharps, flats ]
    end
  end

  [
    [ "C",   0,  0 ], [ "F",   0,  1 ],
    [ "D",   2,  0 ], [ "Bb",  0,  2 ],
    [ "B",   5,  0 ], [ "Gb",  0,  6 ],
    [ "F#",  6,  0 ], [ "Cb",  0,  7 ],
    [ "C#",  7,  0 ], [ "Bbb", 0,  9 ],
    [ "D#",  9,  0 ], [ "Gbb", 0, 13 ],
    [ "E#", 11,  0 ],
    [ "B#", 12,  0 ],
  ].each do |key_name, sharps, flats|
    include_examples "counting accidentals", 1, DiatonicScale::MAJOR, key_name, sharps, flats
    include_examples "counting accidentals", 7, DiatonicScale::MAJOR, key_name, sharps, flats
  end

  [
    [ "C",   0,  1 ], [ "F",   0,  2 ],
    [ "D",   1,  0 ], [ "Bb",  0,  3 ],
    [ "B",   4,  0 ], [ "Gb",  0,  7 ],
    [ "F#",  5,  0 ], [ "Cb",  0,  8 ],
    [ "C#",  6,  0 ], [ "Bbb", 0, 10 ],
    [ "D#",  8,  0 ], [ "Dbb", 0, 13 ],
    [ "E#", 10,  0 ],
    [ "B#", 11,  0 ],
  ].each do |key_name, sharps, flats|
    include_examples "counting accidentals", 2, DiatonicScale::MELODIC_MINOR, key_name, sharps, flats
    include_examples "counting accidentals", 6, DiatonicScale::MELODIC_MINOR, key_name, sharps, flats
  end

  [
    [ "C",   0,  2 ], [ "F",   0,  3 ],
    [ "D",   1,  1 ], [ "Bb",  0,  4 ],
    [ "B",   3,  0 ], [ "Gb",  0,  8 ],
    [ "F#",  4,  0 ], [ "Cb",  0,  9 ],
    [ "C#",  5,  0 ], [ "Bbb", 0, 11 ],
    [ "D#",  7,  0 ], [ "Abb", 0, 13 ],
    [ "E#",  9,  0 ],
    [ "B#", 10,  0 ],
  ].each do |key_name, sharps, flats|
    include_examples "counting accidentals", 3, DiatonicScale::HARMONIC_MINOR, key_name, sharps, flats
    include_examples "counting accidentals", 5, DiatonicScale::HARMONIC_MINOR, key_name, sharps, flats
  end

  [
    [ "C",   0,  1 ], [ "F",   0,  2 ],
    [ "D",   2,  1 ], [ "Bb",  0,  3 ],
    [ "B",   4,  0 ], [ "Gb",  0,  7 ],
    [ "F#",  5,  0 ], [ "Cb",  0,  8 ],
    [ "C#",  6,  0 ], [ "Bbb", 0, 10 ],
    [ "D#",  8,  0 ], [ "Abb", 0, 12 ],
    [ "E#", 10,  0 ],
    [ "B#", 11,  0 ],
  ].each do |key_name, sharps, flats|
    include_examples "counting accidentals", 1, DiatonicScale::HARMONIC_MAJOR, key_name, sharps, flats
    include_examples "counting accidentals", 4, DiatonicScale::HARMONIC_MAJOR, key_name, sharps, flats
  end

  let(:all) { ModeInKey.all(Note.by_name("C")) }

  it "should have 28 modes" do
    all.size.should == 4
    all.each { |modes| modes.size.should == 7 }
  end

  it "should order modes by accidentals" do
    all[0][0].accidentals.should == [ 1, 0 ]
    all[0][1].accidentals.should == [ 0, 0 ]
    all[0][6].accidentals.should == [ 0, 5 ]
  end
end
