require 'note'
require 'clef'
require 'exceptions'

describe Note do
  context "#valid?" do
    it "should identify 'H' as invalid" do
      Note.valid?('H').should be_false
    end

    it "should identify 'a' as invalid" do
      Note.valid?('a').should be_false
    end
  end

  context "#new" do
    it "should raise an exception when given an invalid letter" do
      expect { Note.new('H', -1, 3) }.to \
        raise_exception(NoteExceptions::InvalidLetter, %{No such note with letter 'H'})
    end

    it "should raise pitch mismatch error" do
      expect { Note.new('A', 0, 3) }.to \
        raise_error(NoteExceptions::LetterPitchMismatch, /Pitch mismatch for letter/)
    end
  end

  shared_examples "a note" do |name, ly, pitch, octave, accidental|
    it "should be valid" do
      Note.valid?(name).should be_true
    end

    it "should have the right letter" do
      note.letter.should == name[0]
    end

    it "should have the right pitch" do
      note.pitch.should == pitch
    end

    it "should have the right octave" do
      note.octave.should == octave
    end

    it "should have the right name" do
      note.name.sub(/\d+$/, '').should == name.sub(/\d+$/, '')
    end

    it "should convert to the right string" do
      note.to_s.should == name
    end

    it "should have the right LilyPond code" do
      note.to_ly.should == ly
    end

    it "should have the right accidental" do
      note.accidental.should == accidental
    end
  end

  context "constructing #by_letter" do
    context "A" do
      let(:note) { Note.by_letter('A') }
      it_should_behave_like "a note", "A4", "a", 69, 4, 0
    end

    context "invalid letter" do
      it "should raise an exception when given an invalid letter" do
        expect { Note.by_letter('H') }.to \
          raise_exception(NoteExceptions::InvalidLetter, %{No such note with letter 'H'})
      end
    end
  end

  NOTES = [
    [ "B#",  "bs",   0 + 60, +1 ],
    [ "C",   "c",    0 + 60,  0 ],
    [ "Dbb", "dff",  0 + 60, -2 ],

    [ "Bx",  "bss",  1 + 60, +2 ],
    [ "C#",  "cs",   1 + 60, +1 ],
    [ "Db",  "df",   1 + 60, -1 ],

    [ "Cx",  "css",  2 + 60, +2 ],
    [ "D",   "d",    2 + 60,  0 ],
    [ "Ebb", "eff",  2 + 60, -2 ],

    [ "Dx",  "dss",  4 + 60, +2 ],
    [ "Fb",  "ff",   4 + 60, -1 ],

    [ "Gx",  "gss",  9 + 60, +2 ],
    [ "A",   "a",    9 + 60,  0 ],
    [ "Bbb", "bff",  9 + 60, -2 ],

    [ "A#",  "as",  10 + 60,  1 ],
    [ "Bb",  "bf",  10 + 60, -1 ],
    [ "Cbb", "cff", 10 + 60, -2 ],

    [ "Ax",  "ass", 11 + 60, +2 ],
    [ "B",   "b",   11 + 60,  0 ],
    [ "Cb",  "cf",  11 + 60, -1 ],
  ]

  context "constructing #by_letter_and_pitch" do
    NOTES.each do |name, ly, pitch, accidental|
      name += '4'
      context name do
        let(:note) { Note.by_letter_and_pitch(name[0], pitch) }
        it_should_behave_like "a note", name, ly, pitch, 4, accidental
      end
    end

    context "invalid input" do
      it "should raise error with invalid letter" do
        expect { Note.by_letter_and_pitch('H', 0) }.to \
          raise_error(NoteExceptions::InvalidLetter, /No such note with letter/)
      end

      shared_examples "pitch mismatch" do |letter, pitch|
        it "should raise error with pitch #{pitch} for #{letter}" do
          expect { Note.by_letter_and_pitch(letter, pitch) }.to \
            raise_error(NoteExceptions::LetterPitchMismatch, /Pitch mismatch for letter/)
        end
      end

      it_should_behave_like "pitch mismatch", 'A', 6
      it_should_behave_like "pitch mismatch", 'A', 0
      it_should_behave_like "pitch mismatch", 'B', 8
      it_should_behave_like "pitch mismatch", 'B', 2
      it_should_behave_like "pitch mismatch", 'C', 9
      it_should_behave_like "pitch mismatch", 'C', 3
    end
  end

  context "" do
    shared_examples "a note by name" do |by_name, name, ly, pitch, octave, accidental|
      context "constructing #by_name" do
        let(:note) { Note.by_name(by_name) }
        it_should_behave_like "a note", name, ly, pitch, octave, accidental
      end
      context "constructing by #[]" do
        let(:note) { Note[by_name] }
        it_should_behave_like "a note", name, ly, pitch, octave, accidental
      end
    end

    NOTES.each do |octaveless_name, ly, pitch, accidental|
      [ '', '4', '5' ].each do |suffix|
        by_name = octaveless_name + suffix
        octave = suffix.empty? ? 4 : suffix.to_i
        name = octaveless_name + octave.to_s
        pitch += (octave - 4) * 12
        it_should_behave_like "a note by name", by_name, name, ly, pitch, octave, accidental
      end
    end
  end

  context "#letter_shift" do
    it "should shift 0 letters" do
      Note.letter_shift('B', 0).should == 'B'
    end

    context "no wrap" do
      it "should shift up 1 letter" do
        Note.letter_shift('B', 1).should == 'C'
      end
      it "should shift down 1 letter" do
        Note.letter_shift('C', -1).should == 'B'
      end
      it "should shift up 4 letters" do
        Note.letter_shift('D', 4).should == 'A'
      end
    end

    context "wrap" do
      it "should shift down 1 letter and wrap" do
        Note.letter_shift('A', -1).should == 'G'
      end
      it "should shift up 4 letters and wrap" do
        Note.letter_shift('B', 4).should == 'F'
      end
    end
  end

  describe "#letter_index" do
    tests = [
      [ 'C2'  , -14 ], [ 'D2'  , -13 ], [ 'G2'  , -10 ], [ 'B2'  , -8 ],
      [ 'C#2' , -14 ], [ 'D#2' , -13 ], [ 'G#2' , -10 ], [ 'B#3' , -8 ],
      [ 'Cx2' , -14 ], [ 'Dx2' , -13 ], [ 'Gx2' , -10 ], [ 'Bx3' , -8 ],
      [ 'Cb1' , -14 ], [ 'Db2' , -13 ], [ 'Gb2' , -10 ], [ 'Bb2' , -8 ],
      [ 'Cbb1', -14 ], [ 'Dbb2', -13 ], [ 'Gbb2', -10 ], [ 'Bbb2', -8 ],

      [ 'C3'  ,  -7 ], [ 'D3'  ,  -6 ], [ 'G3'  ,  -3 ], [ 'B3'  , -1 ],
      [ 'C#3' ,  -7 ], [ 'D#3' ,  -6 ], [ 'G#3' ,  -3 ], [ 'B#4' , -1 ],
      [ 'Cx3' ,  -7 ], [ 'Dx3' ,  -6 ], [ 'Gx3' ,  -3 ], [ 'Bx4' , -1 ],
      [ 'Cb2' ,  -7 ], [ 'Db3' ,  -6 ], [ 'Gb3' ,  -3 ], [ 'Bb3' , -1 ],
      [ 'Cbb2',  -7 ], [ 'Dbb3',  -6 ], [ 'Gbb3',  -3 ], [ 'Bbb3', -1 ],

      [ 'C4'  ,   0 ], [ 'D4'  ,   1 ], [ 'G4'  ,   4 ], [ 'B4'  ,  6 ],
      [ 'C#4' ,   0 ], [ 'D#4' ,   1 ], [ 'G#4' ,   4 ], [ 'B#5' ,  6 ],
      [ 'Cx4' ,   0 ], [ 'Dx4' ,   1 ], [ 'Gx4' ,   4 ], [ 'Bx5' ,  6 ],
      [ 'Cb3' ,   0 ], [ 'Db4' ,   1 ], [ 'Gb4' ,   4 ], [ 'Bb4' ,  6 ],
      [ 'Cbb3',   0 ], [ 'Dbb4',   1 ], [ 'Gbb4',   4 ], [ 'Bbb4',  6 ],

      [ 'C5'  ,   7 ], [ 'D5'  ,   8 ], [ 'G5'  ,  11 ], [ 'B5'  , 13 ],
      [ 'C#5' ,   7 ], [ 'D#5' ,   8 ], [ 'G#5' ,  11 ], [ 'B#6' , 13 ],
      [ 'Cx5' ,   7 ], [ 'Dx5' ,   8 ], [ 'Gx5' ,  11 ], [ 'Bx6' , 13 ],
      [ 'Cb4' ,   7 ], [ 'Db5' ,   8 ], [ 'Gb5' ,  11 ], [ 'Bb5' , 13 ],
      [ 'Cbb4',   7 ], [ 'Dbb5',   8 ], [ 'Gbb5',  11 ], [ 'Bbb5', 13 ],
    ]

    tests.each do |note_name, expected_index|
      it "should map #{note_name} onto the right letter index" do
        Note[note_name].letter_index.should == expected_index
      end
    end
  end

  context "equality and equivalence" do
    NOTES.each do |name, ly, pitch, accidental|
      context name do
        let(:note1) { Note.new(name[0], accidental, pitch   ) }
        let(:note2) { n = note1.dup; n                        }
        let(:note3) { n = note1.dup; n.octave -= 1; n         }
        let(:note4) { n = note1.dup; n.octave += 1; n         }

        specify "different instances of the same note should be equal" do
          note1.should == note2
        end

        specify "different instances of the same note should be equivalent" do
          note1.should === note2
          note1.equivalent?(note2).should == true
        end

        specify "notes in different octaves should not be equal" do
          note1.should_not == note3
          note3.should_not == note4
        end

        specify "notes in different octaves should be equivalent" do
          note1.should === note3
          note3.equivalent?(note4).should == true
        end
      end
    end

    equivalent_pairs = [ "A#1 Bb1", "B#2 C2", "Dx3 E3", "D4 Ebb4", "Bx5 Db5", "D#6 Fbb6" ]

    specify "enharmonically equivalent notes in same octave should be equivalent" do
      equivalent_pairs.each do |pair|
        a, b = pair.split
        Note[a].should === Note[b]
      end
    end

    specify "enharmonically equivalent notes in same octave should be inequal" do
      equivalent_pairs.each do |pair|
        a, b = pair.split
        Note[a].should_not == Note[b]
      end
    end

    non_equivalent_pairs = [ "A#1 Bb2", "B#2 C3", "Dx3 E2", "D4 Ebb2", "Bx0 Db5", "D#6 Fbb8" ]

    specify "enharmonically equivalent notes in different octaves should be equivalent" do
      non_equivalent_pairs.each do |pair|
        a, b = pair.split
        Note[a].should === Note[b]
      end
    end

    specify "enharmonically equivalent notes in different octaves should be inequal" do
      non_equivalent_pairs.each do |pair|
        a, b = pair.split
        Note[a].should_not == Note[b]
      end
    end
  end

  describe "#simplify" do
    it "should not touch a natural" do
      Note.by_name("B").simplify.should == Note.by_name("B")
    end

    it "should not touch a normal sharp" do
      Note.by_name("G#").simplify.should == Note.by_name("G#")
    end

    it "should not touch a normal flat" do
      Note.by_name("Db").simplify.should == Note.by_name("Db")
    end

    it "should simplify E#" do
      Note.by_name("E#").simplify.should == Note.by_name("F")
    end

    it "should simplify B#" do
      Note.by_name("B#").simplify.should == Note.by_name("C")
    end

    it "should simplify Fb" do
      Note.by_name("Fb").simplify.should == Note.by_name("E")
    end

    it "should simplify Cb" do
      Note.by_name("Cb").simplify.should == Note.by_name("B")
    end

    it "should simplify a double-flat" do
      Note.by_name("Abb").simplify.should == Note.by_name("G")
    end

    it "should simplify a double-sharp" do
      Note.by_name("Cx").simplify.should == Note.by_name("D")
    end
  end

  describe "#simple?" do
    Note::STANDARD_KEYS.each do |note|
      it "should identify #{name} as simple" do
        note.simple?.should be_true
      end
    end

    complex = [ Note::UGLY_NOTES, Note::DOUBLE_SHARPS, Note::DOUBLE_FLATS ]
    complex.flatten.each do |note|
      it "should identify #{note} as not simple" do
        note.simple?.should be_false
      end
    end
  end

  describe ".by_pitch" do
    pitches = [
      [  0, 'C4 Dbb4 B#4' ],
      [  1, 'C#4 Db4 Bx4' ],
      [  2, 'Cx4 D4 Ebb4' ],
      [  3, 'D#4 Eb4 Fbb4'],
      [  4, 'Dx4 E4 Fb4'  ],
      [  5, 'E#4 F4 Gbb4' ],
      [  6, 'Ex4 F#4 Gb4' ],
      [  7, 'Fx4 G4 Abb4' ],
      [  8,   'G#4 Ab4'   ],
      [  9, 'Gx4 A4 Bbb4' ],
      [ 10, 'Cbb4 A#4 Bb4'],
      [ 11, 'Cb4 Ax4 B4'  ],
      [ 12, 'C5 Dbb5 B#5' ],
      [ 13, 'C#5 Db5 Bx5' ],
      [ 14, 'Cx5 D5 Ebb5' ],
    ]
    pitches.each do |pitch, expected|
      context "pitch #{pitch}" do
        let(:notes) { Note.by_pitch(pitch + 60) }

        it "should return Note instances" do
          notes.each { |n| n.is_a?(Note).should be_true }
        end

        specify "pitch #{pitch} should give #{expected} the right notes" do
          notes.join(' ').should == expected
        end
      end
    end
  end

  describe "#octave!" do
    before :each do
      @note = Note['A']
      @orig_pitch = @note.pitch
    end

    it "should leave a note in octave 4" do
      @orig_pitch.should == 69
      @note.octave!(4).pitch.should == @orig_pitch
    end

    it "should move a note down to octave 3" do
      @note.octave!(3).pitch.should == @orig_pitch - 12
    end

    it "should move a note up to octave 6" do
      @note.octave!(6).pitch.should == @orig_pitch + 24
    end
  end

  describe "#octave_squash" do
    it "should leave note untouched in octave 4" do
      note = Note['Bb']
      note.octave_squash.object_id.should == note.object_id
      note.octave.should == 4
    end

    it "should return new note moved down to octave 4" do
      note = Note['Bb5']
      squashed = note.octave_squash
      squashed.pitch.should be_between(60, 71)
      squashed.octave.should == 4
      squashed.object_id.should_not == note.object_id
    end

    it "should return new note moved up to octave 4" do
      note = Note['Bb3']
      squashed = note.octave_squash
      squashed.pitch.should be_between(60, 71)
      squashed.octave.should == 4
      squashed.object_id.should_not == note.object_id
    end
  end

  describe "#octave_squash!" do
    shared_examples "a squashed note" do |spec, name|
      it spec do
        note = Note[name]
        orig_object_id = note.object_id
        note.octave_squash!.object_id.should == orig_object_id
        note.pitch.should be_between(60, 71)
        note.octave.should == 4
      end
    end

    include_examples "a squashed note", "should leave note untouched in octave 4", "Bb"
    include_examples "a squashed note", "should leave note untouched in octave 4", "Bb4"
    include_examples "a squashed note", "should move note up to octave 4",         "Bb3"
    include_examples "a squashed note", "should move note down to octave 4",       "Bb5"
  end

  describe "" do
    notes = [
      [ "Bb3",  "B3" ],
      [ "Cbb3", "C4" ],

      [ "B3",   "B3" ],
      [ "Cb3",  "C4" ],

      [ "B#4",  "B3" ],
      [ "C4",   "C4" ],
      [ "Dbb4", "D4" ],

      [ "C#4",  "C4" ],
      [ "Db4",  "D4" ],
    ]

    notes.each do |name, natural|
      specify "naturalize! should naturalize #{name}" do
        note = Note[name]
        orig_object_id = note.object_id
        natural = Note[natural]
        note.naturalize!
        note.object_id.should == orig_object_id
        note.name_with_octave.should == natural.name_with_octave
        note.pitch.should == natural.pitch
      end
    end

    notes.each do |name, natural|
      specify "naturalize should naturalize #{name}" do
        note = Note[name]
        naturalized = note.naturalize
        natural = Note[natural]
        naturalized.name_with_octave.should == natural.name_with_octave
        naturalized.pitch.should == natural.pitch
        if name == natural.name_with_octave
          naturalized.object_id.should == note.object_id
        else
          naturalized.object_id.should_not == note.object_id
        end
      end
    end
  end

  describe "#to_ly_abs" do
    notes = [
      [ "Bb1",  "bf,," ], [ "Bb2",  "bf," ], [ "Bb3",  "bf"   ], [ "Bb4",  "bf'"   ],
      [ "Cbb1", "cff," ], [ "Cbb2", "cff" ], [ "Cbb3", "cff'" ], [ "Cbb4", "cff''" ],

      [ "B1",   "b,,"  ], [ "B2",   "b,"  ], [ "B3",   "b"    ], [ "B4",   "b'"    ],
      [ "Cb1",  "cf,"  ], [ "Cb2",  "cf"  ], [ "Cb3",  "cf'"  ], [ "Cb4",  "cf''"  ],

      [ "B#2",  "bs,," ], [ "B#3",  "bs," ], [ "B#4",  "bs"   ], [ "B#5",  "bs'"   ],
      [ "C2",   "c,"   ], [ "C3",   "c"   ], [ "C4",   "c'"   ], [ "C5",   "c''"   ],
      [ "Dbb2", "dff," ], [ "Dbb3", "dff" ], [ "Dbb4", "dff'" ], [ "Dbb5", "dff''" ],

      [ "C#2",  "cs,"  ], [ "C#3",  "cs"  ], [ "C#4",  "cs'"  ], [ "C#5",  "cs''"  ],
      [ "Db2",  "df,"  ], [ "Db3",  "df"  ], [ "Db4",  "df'"  ], [ "Db5",  "df''"  ],
    ]

    notes.each do |name, ly|
      it "should get the right LilyPond absolute pitch notation for #{name}" do
        Note[name].to_ly_abs.should == ly
      end
    end
  end

  describe "#to_ly_markup" do
    notes = [
      [ "A",   "A\\raise #0.5 \\fontsize #-3 \\natural"     ],
      [ "B",   "B\\raise #0.5 \\fontsize #-3 \\natural"     ],
      [ "C",   "C\\raise #0.5 \\fontsize #-3 \\natural"     ],
      [ "Ab",  "A\\raise #0.5 \\fontsize #-3 \\flat"        ],
      [ "Abb", "A\\raise #0.5 \\fontsize #-3 \\doubleflat"  ],
      [ "G#",  "G\\raise #0.5 \\fontsize #-3 \\sharp"       ],
      [ "Gx",  "G\\raise #0.5 \\fontsize #-3 \\doublesharp" ],
    ]

    notes.each do |name, markup|
      it "should have the right markup" do
        Note[name].to_ly_markup.should == markup
      end
    end
  end

  describe "#clef_position" do
    tests = [
      [ 'C4' , 'treble', -6 ], [ 'D3' , 'alto', -6 ], [ 'B2' , 'tenor',  -6 ], [ 'E2' , 'bass', -6 ],
      [ 'D4' , 'treble', -5 ], [ 'E3' , 'alto', -5 ], [ 'C3' , 'tenor',  -5 ], [ 'F2' , 'bass', -5 ],
      [ 'E4' , 'treble', -4 ], [ 'F3' , 'alto', -4 ], [ 'D3' , 'tenor',  -4 ], [ 'G2' , 'bass', -4 ],
      [ 'B4' , 'treble',  0 ], [ 'C4' , 'alto',  0 ], [ 'A3' , 'tenor',   0 ], [ 'D3' , 'bass',  0 ],
      [ 'E5' , 'treble',  3 ], [ 'F4' , 'alto',  3 ], [ 'D4' , 'tenor',   3 ], [ 'G3' , 'bass',  3 ],
      [ 'E6' , 'treble', 10 ], [ 'F5' , 'alto', 10 ], [ 'D5' , 'tenor',  10 ], [ 'G4' , 'bass', 10 ],

      [ 'B#4', 'treble', -7 ], [ 'B#4', 'alto', -1 ], [ 'B#4', 'tenor',   1 ], [ 'B#4', 'bass',  5 ],
      [ 'Cb3', 'treble', -6 ], [ 'Cb3', 'alto',  0 ], [ 'Cb3', 'tenor',   2 ], [ 'Cb3', 'bass',  6 ],
      [ 'C#4', 'treble', -6 ], [ 'C#4', 'alto',  0 ], [ 'C#4', 'tenor',   2 ], [ 'C#4', 'bass',  6 ],
    ]

    tests.each do |note_name, clef_name, expected_position|
      clef = Clef[clef_name]
      it "should have #{clef} clef position #{expected_position} for #{note_name}" do
        Note[note_name].clef_position(clef).should == expected_position
      end
    end
  end

end
