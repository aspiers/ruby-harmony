require 'note'
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

    it "should have the right LilyPond absolute code" do
      note.to_ly_abs.should == ly + ("'" * (octave - 3))
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
        note = Note.new(letter, accidental, pitch + 60)
        note.to_ly_abs.should == ly
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
end
