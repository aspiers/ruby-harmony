require 'note'
require 'exceptions'

describe Note do
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

  shared_examples "a note" do |name, letter, ly, pitch, accidental|
    it "should have the right letter (#{letter})" do
      note.letter.should == letter
    end

    it "should have the right pitch (#{pitch})" do
      note.pitch.should == pitch
    end

    it "should have the right name (#{name})" do
      note.name.should == name
    end

    it "should have the right LilyPond code (#{ly})" do
      note.to_ly.should == ly
    end

    it "should have the right LilyPond absolute code (#{ly})" do
      note.to_ly_abs.should == ly + "'"
    end

    it "should have the right accidental (#{accidental})" do
      note.accidental.should == accidental
    end
  end

  context "constructing #by_letter" do
    context "A" do
      let(:note) { Note.by_letter('A') }
      it_should_behave_like "a note", "A", "A", "a", 9, 0
    end

    context "invalid letter" do
      it "should raise an exception when given an invalid letter" do
        expect { Note.by_letter('H') }.to \
          raise_exception(NoteExceptions::InvalidLetter, %{No such note with letter 'H'})
      end
    end
  end

  NOTES = [
    [ "Gx",  "gss",  9, +2 ],
    [ "A",   "a",    9,  0 ],
    [ "Bbb", "bff",  9, -2 ],

    [ "A#",  "as",  10,  1 ],
    [ "Bb",  "bf",  10, -1 ],
    [ "Cbb", "cff", 10, -2 ],

    [ "Ax",  "ass", 11, +2 ],
    [ "B",   "b",   11,  0 ],
    [ "Cb",  "cf",  11, -1 ],

    [ "B#",  "bs",   0, +1 ],
    [ "C",   "c",    0,  0 ],
    [ "Dbb", "dff",  0, -2 ],

    [ "Bx",  "bss",  1, +2 ],
    [ "C#",  "cs",   1, +1 ],
    [ "Db",  "df",   1, -1 ],

    [ "Cx",  "css",  2, +2 ],
    [ "D",   "d",    2,  0 ],
    [ "Ebb", "eff",  2, -2 ],

    [ "Dx",  "dss",  4, +2 ],
    [ "Fb",  "ff",   4, -1 ],
  ]

  context "constructing #by_letter_and_pitch" do
    NOTES.each do |name, ly, pitch, accidental|
      context name do
        let(:note) { Note.by_letter_and_pitch(name[0], pitch) }
        it_should_behave_like "a note", name, name[0], ly, pitch, accidental
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

  context "constructing #by_name" do
    shared_examples "a note by name" do |name, ly, pitch, accidental|
      let(:note) { Note.by_name(name) }
      it_should_behave_like "a note", name, name[0], ly, pitch, accidental
    end

    NOTES.each do |name, ly, pitch, accidental|
      it_should_behave_like "a note by name", name, ly, pitch, accidental
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

  context "equality and equivalence" do
    NOTES.each do |name, ly, pitch, accidental|
      context name do
        let(:note1) { Note.new(name[0], accidental, pitch   ) }
        let(:note2) { n = note1.dup; n.octave -= 1; n         }
        let(:note3) { n = note1.dup; n.octave += 1; n         }

        specify "notes in different octaves should not be equal" do
          note1.should_not == note2
          note2.should_not == note3
        end

        specify "notes in different octaves should be equivalent" do
          note1.should === note2
          note2.equivalent?(note3).should == true
        end
      end
    end
  end

  describe "#simplify" do
    it "should not touch a natural" do
      Note.by_name("G").simplify.should == Note.by_name("G")
    end

    it "should not touch a sharp" do
      Note.by_name("G#").simplify.should == Note.by_name("G#")
    end

    it "should not touch a flat" do
      Note.by_name("Db").simplify.should == Note.by_name("Db")
    end

    it "should simplify a double-flat" do
      Note.by_name("Abb").simplify.should == Note.by_name("G")
    end

    it "should simplify a double-sharp" do
      Note.by_name("Cx").simplify.should == Note.by_name("D")
    end
  end

  describe ".by_pitch" do
    pitches = [
      [  0, 'C Dbb B#' ],
      [  1, 'C# Db Bx' ],
      [  2, 'Cx D Ebb' ],
      [  3, 'D# Eb Fbb'],
      [  4, 'Dx E Fb'  ],
      [  5, 'E# F Gbb' ],
      [  6, 'Ex F# Gb' ],
      [  7, 'Fx G Abb' ],
      [  8,  'G# Ab'   ],
      [  9, 'Gx A Bbb' ],
      [ 10, 'Cbb A# Bb'],
      [ 11, 'Cb Ax B'  ],
      [ 12, 'C Dbb B#' ],
      [ 13, 'C# Db Bx' ],
      [ 14, 'Cx D Ebb' ],
    ]
    pitches.each do |pitch, expected|
      specify "pitch #{pitch} should give #{expected} the right notes" do
        Note.by_pitch(pitch).join(' ').should == expected
      end
    end
  end

  describe "#to_ly_abs" do
    notes = [
      [ "B", -13,  0,  "b,"   ],
      [ "C", -12,  0,  "c"    ],
      [ "B",  -1,  0,  "b"    ],
      [ "C",   0,  0,  "c'"   ],
      [ "A",   9,  0,  "a'"   ],
      [ "B",  11,  0,  "b'"   ],
      [ "C",  12,  0,  "c''"  ],
      [ "D",  14,  0,  "d''"  ],
      [ "E",  15, -1,  "ef''" ],
      [ "B",  23,  0,  "b''"  ],
      [ "C",  24,  0,  "c'''" ],
    ]

    notes.each do |letter, pitch, accidental, ly|
      it "should handle octave 1 right" do
        note = Note.new(letter, accidental, pitch)
        note.to_ly_abs.should == ly
      end
    end
  end
end
