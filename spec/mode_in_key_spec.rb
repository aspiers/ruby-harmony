require 'mode_in_key'
require 'scale_type'
require 'mode'

describe ModeInKey do
  describe "standard methods" do
    [
      [
        1, "F#",  DiatonicScaleType::MAJOR,
        "F# ionian\n(F# maj)",
        'F# G# A# B C# D# E#',
        [ 6, 8, 10, 11, 13, 15, 17 ],
        <<-'EOF',
            \override #'(baseline-skip . 2)
            \column {
              \line { "F# ionian" }
              \line { "(F# maj)" }
            }
        EOF
      ],
      [
        2, "C",  DiatonicScaleType::MAJOR,
        "D dorian\n(2nd degree of C maj)",
        "D E F G A B C",
        [ 2, 4, 5, 7, 9, 11, 12 ],
        <<-'EOF',
            \override #'(baseline-skip . 2)
            \column {
              \line { "D dorian" }
              \line { "(2nd degree of C maj)" }
            }
        EOF
      ],
      [
        6, "F",  DiatonicScaleType::MAJOR,
        "D aeolian\n(6th degree of F maj)",
        "D E F G A Bb C",
        [ 2, 4, 5, 7, 9, 10, 12 ],
        <<-'EOF',
            \override #'(baseline-skip . 2)
            \column {
              \line { "D aeolian" }
              \line { "(6th degree of F maj)" }
            }
        EOF
      ],
      [
        4, "G",  DiatonicScaleType::MELODIC_MINOR,
        "C lydian dominant\n(4th degree of G mel min)",
        "C D E F# G A Bb",
        [ 0, 2, 4, 6, 7, 9, 10 ],
        <<-'EOF',
            \override #'(baseline-skip . 2)
            \column {
              \line { "C lydian dominant" }
              \line { "(4th degree of G mel min)" }
            }
        EOF
      ],
      [
        6, "F",  DiatonicScaleType::MELODIC_MINOR,
        "D locrian natural 2\n(6th degree of F mel min)",
        "D E F G Ab Bb C",
        [ 2, 4, 5, 7, 8, 10, 12 ],
        <<-'EOF',
            \override #'(baseline-skip . 2)
            \column {
              \line { "D locrian natural 2" }
              \line { "(6th degree of F mel min)" }
            }
        EOF
      ],
      [
        4, "Bb", DiatonicScaleType::MELODIC_MINOR,
        "Eb lydian dominant\n(4th degree of Bb mel min)",
        "Eb F G A Bb C Db",
        [ 3, 5, 7, 9, 10, 12, 13 ],
        <<-'EOF',
            \override #'(baseline-skip . 2)
            \column {
              \line { "Eb lydian dominant" }
              \line { "(4th degree of Bb mel min)" }
            }
        EOF
      ],
      [
        6, "E", DiatonicScaleType::HARMONIC_MAJOR,
        "C lydian #2 #5\n(6th degree of E harm maj)",
        "C D# E F# G# A B",
        [ 0, 3, 4, 6, 8, 9, 11 ],
        <<-'EOF',
            \override #'(baseline-skip . 2)
            \column {
              \line { "C lydian #2 #5" }
              \line { "(6th degree of E harm maj)" }
            }
        EOF
      ],
      [
        1, "Ab", SymmetricalScaleType::DIMINISHED,
        "Ab diminished",
        "Ab Bb B Db D E F G",
        [ 8, 10, 11, 13, 14, 16, 17, 19 ],
        <<-'EOF',
            "Ab diminished"
        EOF
      ],
      [
        2, "Bb", SymmetricalScaleType::DIMINISHED,
        "C auxiliary diminished\n(2nd degree of Bb diminished)",
        "C Db Eb E Gb G A Bb",
        [ 0, 1, 3, 4, 6, 7, 9, 10 ],
        <<-'EOF',
            \override #'(baseline-skip . 2)
            \column {
              \line { "C auxiliary diminished" }
              \line { "(2nd degree of Bb diminished)" }
            }
        EOF
      ],
      [
        1, "G",  SymmetricalScaleType::WHOLE_TONE,
        "G whole tone",
        "G A B C# D# F",
        [ 7, 9, 11, 13, 15, 17 ],
        "            \"G whole tone\"\n"
      ],
    ].each do
      |degree, key_name, scale_type,
       exp_long_name, exp_notes, exp_pitches, exp_ly|

      context "degree #{degree} of #{key_name} #{scale_type}" do
        let(:mode)        { Mode.new(degree, scale_type)  }
        let(:key)         { Note[key_name]                }
        let(:mode_in_key) { ModeInKey.new(mode, key)      }
        let(:short_name)  { exp_long_name.sub(/\n.+/, '') }

        it "should give its short name via #inspect" do
          mode_in_key.inspect.should == short_name
        end

        it "should have the long name" do
          mode_in_key.name.should == exp_long_name
        end

        it "should have the right LilyPond markup" do
          mode_in_key.to_ly.should == exp_ly
        end

        it "should have the right note names" do
          mode_in_key.notes.join(' ').should == exp_notes
        end

        it "should have the right pitches" do
          mode_in_key.pitches.should == exp_pitches
        end
      end
    end
  end

  shared_examples "key choice" do
    |scale_type, starting_note_name, degree,
     exp_original_key, exp_degree, exp_key, exp_notes, exp_name|

    context "degree #{degree} as #{starting_note_name}" do
      let(:mode)          { Mode.new(degree, scale_type) }
      let(:starting_note) { Note[starting_note_name] }
      let(:mode_in_key)   { ModeInKey.by_start_note(mode, starting_note) }

      it "should calculate the right original key" do
        mode_in_key.original.key_note.name.should == exp_original_key
      end

      it "should calculate the right degree" do
        mode_in_key.mode.degree.should == exp_degree
      end
      
      it "should choose the right key" do
        mode_in_key.key_note.name.should == exp_key
      end

      it "should calculate the right original degree" do
        mode_in_key.original.mode.degree.should == mode.degree
      end

      it "should return the right notes" do
        mode_in_key.notes.map(&:to_s).should == exp_notes.split
      end

      it "should return the name" do
        mode_in_key.original.name.should == exp_name
      end
    end
  end

  describe "key choice in symmetrical scales" do
    [
      [
        'C',  1, 'C',  1, 'C',  'C  D  Eb F  Gb Ab A  B' ,
        "C diminished"
      ],
      [
        'C',  2, 'Bb', 4, 'G',  'C  Db Eb E  F# G  A  Bb',
        "C auxiliary diminished\n(2nd degree of Bb diminished)"
      ],
      [
        'C#', 1, 'C#', 7, 'E',  'C# D# E  F# G  A  Bb C',
        "C# diminished"
      ],
      [
        'C#', 2, 'B',  2, 'B',  'C# D  E  F  G  G#  A# B',
        "C# auxiliary diminished\n(2nd degree of B diminished)"
      ],
      [
        'D',  1, 'D',  1, 'D',  'D  E  F  G  Ab Bb B  C#',
        "D diminished",
      ],
      [
        'D',  2, 'C',  2, 'C',  'D  Eb F  Gb Ab A  B  C',
        "D auxiliary diminished\n(2nd degree of C diminished)",
      ],
    ].each do |data|
      include_examples "key choice", SymmetricalScaleType::DIMINISHED, *data
    end
  end

  shared_examples "counting accidentals" do |degree, scale_type, key_name, sharps, flats|
    mode = Mode.new(degree, scale_type)
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

  describe ".all_for_scale_type" do
    let(:all) { ModeInKey.all_for_scale_type(DiatonicScaleType::MELODIC_MINOR, Note["C"]) }

    it "should have 7 modes" do
      all.size.should == 7
    end

    it "should order modes by accidentals" do
      all[0].accidentals.should == [ 2, 0 ]
      all[1].accidentals.should == [ 1, 1 ]
      all[6].accidentals.should == [ 0, 6 ]
      all[0].generic_description.should == '3rd degree of A mel min'
      all[1].generic_description.should == '4th degree of G mel min'
      all[6].generic_description.should == '7th degree of Db mel min'
      all[0].notes.join(' ').should == 'C D E F# G# A B'
      all[1].notes.join(' ').should == 'C D E F# G A Bb'
      all[6].notes.join(' ').should == 'C Db Eb Fb Gb Ab Bb'
    end
  end

  describe ".all" do
    let(:all) { ModeInKey.all(Note.by_name("C")) }

    it "should have at least 28 modes" do
      all.size.should >= 4
      all.each do |modes_in_key|
        modes_in_key.size.should == modes_in_key[0].mode.scale_type.num_modes
      end
    end
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

2 C auxiliary diminished         C   Db  Eb  E   F#  G   A   Bb 
1 C diminished                   C   D   Eb  F   Gb  Ab  A   B  

1 C augmented                    C   D#  E   G   Ab  B  
2 2nd degree of A augmented      C   Db  E   F   G#  A  

EOF
    end
  end
end
