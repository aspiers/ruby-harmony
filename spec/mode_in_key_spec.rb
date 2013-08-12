require 'mode_in_key'
require 'scale_type'
require 'mode'

describe ModeInKey do
  describe "#name" do
    [
      [ 2, "C",  DiatonicScaleType::MAJOR,         "D dorian\n(2nd degree of C maj)"      ],
      [ 6, "F",  DiatonicScaleType::MAJOR,         "D aeolian\n(6th degree of F maj)"     ],
      [ 4, "G",  DiatonicScaleType::MELODIC_MINOR, "C lydian dominant\n(4th degree of G mel min)"   ],
      [ 6, "F",  DiatonicScaleType::MELODIC_MINOR, "D locrian natural 2\n(6th degree of F mel min)" ],
      [ 2, "Ab", SymmetricalScaleType::DIMINISHED, "Bb auxiliary diminished\n(2nd degree of Ab dim)" ],
      [ 1, "G",  SymmetricalScaleType::WHOLE_TONE, "G whole tone" ],
    ].each do |degree, key_name, scale_type, expected|
      context "degree #{degree} of #{key_name} #{scale_type}" do
        let(:mode) { Mode.new(degree, scale_type, 0) }
        let(:key)  { Note[key_name]                  }
        let(:mode_in_key) { ModeInKey.new(mode, key) }
        let(:short_name) { expected.sub(/\n.+/, '')  }

        it "should have the long name" do
          mode_in_key.name.should == expected
        end

        it "should give its short name via #inspect" do
          mode_in_key.inspect.should == short_name
        end
      end
    end
  end

  shared_examples "notes" do |degree, scale_type, key_name, expected_notes, expected_pitches|
    context "#{key_name} #{scale_type} degree #{degree}" do
      let(:mode)        { Mode.new(degree, scale_type, -1) }
      let(:key_note)    { Note.by_name(key_name) }
      let(:mode_in_key) { ModeInKey.new(mode, key_note) }

      it "should have the right notes" do
        mode_in_key.notes.join(' ').should == expected_notes
      end

      it "should have the right pitches" do
        mode_in_key.pitches.should == expected_pitches
      end
    end
  end

  include_examples "notes", 4, DiatonicScaleType::MELODIC_MINOR, "Bb",
    'Eb F G A Bb C Db', [ 3, 5, 7, 9, 10, 12, 13 ]

  include_examples "notes", 6, DiatonicScaleType::HARMONIC_MAJOR, "E",
    'C D# E F# G# A B', [ 0, 3, 4, 6, 8, 9, 11 ]

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

    it "#{mode_in_key} should have the right accidental count" do
      mode_in_key.num_accidentals.should == sharps + flats
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
    include_examples "counting accidentals", 1, DiatonicScaleType::MAJOR, key_name, sharps, flats
    include_examples "counting accidentals", 7, DiatonicScaleType::MAJOR, key_name, sharps, flats
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
    include_examples "counting accidentals", 2, DiatonicScaleType::MELODIC_MINOR, key_name, sharps, flats
    include_examples "counting accidentals", 6, DiatonicScaleType::MELODIC_MINOR, key_name, sharps, flats
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
    include_examples "counting accidentals", 3, DiatonicScaleType::HARMONIC_MINOR, key_name, sharps, flats
    include_examples "counting accidentals", 5, DiatonicScaleType::HARMONIC_MINOR, key_name, sharps, flats
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
    include_examples "counting accidentals", 1, DiatonicScaleType::HARMONIC_MAJOR, key_name, sharps, flats
    include_examples "counting accidentals", 4, DiatonicScaleType::HARMONIC_MAJOR, key_name, sharps, flats
  end

  let(:all) { ModeInKey.all(Note.by_name("C")) }

  it "should have at least 28 modes" do
    all.size.should >= 4
    all.each do |modes_in_key|
      modes_in_key.size.should == modes_in_key[0].mode.scale_type.num_modes
    end
  end

  it "should order modes by accidentals" do
    all[0][0].accidentals.should == [ 1, 0 ]
    all[0][1].accidentals.should == [ 0, 0 ]
    all[0][6].accidentals.should == [ 0, 5 ]
  end

  describe "#output_modes" do
    it "should show all the scales in D" do
      ModeInKey.output_modes(Note['D']).should == <<EOF
4 lydian                         D   E   F#  G#  A   B   C# 
1 ionian                         D   E   F#  G   A   B   C# 
5 mixo                           D   E   F#  G   A   B   C  
2 dorian                         D   E   F   G   A   B   C  
6 aeolian                        D   E   F   G   A   Bb  C  
3 phrygian                       D   Eb  F   G   A   Bb  C  
7 locrian                        D   Eb  F   G   Ab  Bb  C  

3 lydian augmented               D   E   F#  G#  A#  B   C# 
4 lydian dominant                D   E   F#  G#  A   B   C  
1 D mel min                      D   E   F   G   A   B   C# 
5 dominant b13                   D   E   F#  G   A   Bb  C  
2 dorian b2                      D   Eb  F   G   A   B   C  
6 locrian natural 2              D   E   F   G   Ab  Bb  C  
7 altered                        D   Eb  F   Gb  Ab  Bb  C  

6 6th degree of F# harm min      D   E#  F#  G#  A   B   C# 
3 3rd degree of B harm min       D   E   F#  G   A#  B   C# 
4 4th degree of A harm min       D   E   F   G#  A   B   C  
1 D harm min                     D   E   F   G   A   Bb  C# 
5 5th degree of G harm min       D   Eb  F#  G   A   Bb  C  
2 2nd degree of C harm min       D   Eb  F   G   Ab  B   C  
7 7th degree of Eb harm min      D   Eb  F   Gb  Ab  Bb  Cb 

6 6th degree of F# harm maj      D   E#  F#  G#  A#  B   C# 
4 4th degree of A harm maj       D   E   F   G#  A   B   C# 
1 D harm maj                     D   E   F#  G   A   Bb  C# 
5 5th degree of G harm maj       D   Eb  F#  G   A   B   C  
2 2nd degree of C harm maj       D   E   F   G   Ab  B   C  
3 3rd degree of Bb harm maj      D   Eb  F   Gb  A   Bb  C  
7 7th degree of Eb harm maj      D   Eb  F   G   Ab  Bb  Cb 

1 whole tone                     D   E   F#  G#  A#  B# 

1 D dim                          D   E   F   G   Ab  Bb  B   C# 
2 auxiliary diminished           D   Eb  F   Gb  Ab  A   B   C  

EOF
    end
  end
end
