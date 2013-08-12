require 'mode_in_key'
require 'scale_type'
require 'mode'

describe ModeInKey do
  describe "#name and #to_ly" do
    [
      [ 2, "C",  DiatonicScaleType::MAJOR,         "D dorian\n(2nd degree of C maj)",
        <<-'EOF'
            \override #'(baseline-skip . 2)
            \column {
              \line { "D dorian" }
              \line { "(2nd degree of C maj)" }
            }
        EOF
      ],
      [ 6, "F",  DiatonicScaleType::MAJOR,         "D aeolian\n(6th degree of F maj)",
        <<-'EOF'
            \override #'(baseline-skip . 2)
            \column {
              \line { "D aeolian" }
              \line { "(6th degree of F maj)" }
            }
        EOF
      ],
      [ 4, "G",  DiatonicScaleType::MELODIC_MINOR, "C lydian dominant\n(4th degree of G mel min)",
        <<-'EOF'
            \override #'(baseline-skip . 2)
            \column {
              \line { "C lydian dominant" }
              \line { "(4th degree of G mel min)" }
            }
        EOF
      ],
      [ 6, "F",  DiatonicScaleType::MELODIC_MINOR, "D locrian natural 2\n(6th degree of F mel min)",
        <<-'EOF'
            \override #'(baseline-skip . 2)
            \column {
              \line { "D locrian natural 2" }
              \line { "(6th degree of F mel min)" }
            }
        EOF
      ],
      [ 2, "Ab", SymmetricalScaleType::DIMINISHED, "Bb auxiliary diminished\n(2nd degree of Ab dim)",
        <<-'EOF'
            \override #'(baseline-skip . 2)
            \column {
              \line { "Bb auxiliary diminished" }
              \line { "(2nd degree of Ab dim)" }
            }
        EOF
      ],
      [ 1, "G",  SymmetricalScaleType::WHOLE_TONE, "G whole tone",
        "            \"G whole tone\"\n"
      ],
    ].each do |degree, key_name, scale_type, long_name, ly|
      context "degree #{degree} of #{key_name} #{scale_type}" do
        let(:mode) { Mode.new(degree, scale_type, 0) }
        let(:key)  { Note[key_name]                  }
        let(:mode_in_key) { ModeInKey.new(mode, key) }
        let(:short_name) { long_name.sub(/\n.+/, '')  }

        it "should give its short name via #inspect" do
          mode_in_key.inspect.should == short_name
        end

        it "should have the long name" do
          mode_in_key.name.should == long_name
        end

        it "should have the right LilyPond markup" do
          mode_in_key.to_ly.should == ly
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
    it "should show all the scales in C" do
      ModeInKey.output_modes(Note['C']).should == <<EOF
4 C lydian                       C   D   E   F#  G   A   B  
1 C ionian                       C   D   E   F   G   A   B  
5 C mixo                         C   D   E   F   G   A   Bb 
2 C dorian                       C   D   Eb  F   G   A   Bb 
6 C aeolian                      C   D   Eb  F   G   Ab  Bb 
3 C phrygian                     C   Db  Eb  F   G   Ab  Bb 
7 C locrian                      C   Db  Eb  F   Gb  Ab  Bb 

3 C lydian augmented             C   D   E   F#  G#  A   B  
4 C lydian dominant              C   D   E   F#  G   A   Bb 
1 C mel min                      C   D   Eb  F   G   A   B  
5 C dominant b13                 C   D   E   F   G   Ab  Bb 
2 C dorian b2                    C   Db  Eb  F   G   A   Bb 
6 C locrian natural 2            C   D   Eb  F   Gb  Ab  Bb 
7 C altered                      C   Db  Eb  Fb  Gb  Ab  Bb 

6 C lydian #2                    C   D#  E   F#  G   A   B  
3 C major #5                     C   D   E   F   G#  A   B  
4 C dorian #4                    C   D   Eb  F#  G   A   Bb 
1 C harm min                     C   D   Eb  F   G   Ab  B  
5 C dominant b9 b13              C   Db  E   F   G   Ab  Bb 
2 C locrian natural 6            C   Db  Eb  F   Gb  A   Bb 
7 7th degree of Db harm min      C   Db  Eb  Fb  Gb  Ab  Bbb

6 C lydian #2 #5                 C   D#  E   F#  G#  A   B  
4 C melodic min #4               C   D   Eb  F#  G   A   B  
1 C harm maj                     C   D   E   F   G   Ab  B  
5 C dominant b9                  C   Db  E   F   G   A   Bb 
2 2nd degree of Bb harm maj      C   D   Eb  F   Gb  A   Bb 
3 3rd degree of Ab harm maj      C   Db  Eb  Fb  G   Ab  Bb 
7 7th degree of Db harm maj      C   Db  Eb  F   Gb  Ab  Bbb

1 C whole tone                   C   D   E   F#  G#  A# 

4 4th degree of G dim            C   Db  Eb  E   F#  G   A   Bb 
1 C dim                          C   D   Eb  F   Gb  Ab  A   B  

EOF
    end
  end
end
