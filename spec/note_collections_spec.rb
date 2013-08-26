require 'note'
require 'note_collections'
require 'clef'

describe NoteSet do
  describe "#num_letters" do
    shared_examples "letter set" do |expected, letters|
      it "should count the letters in #{letters}" do
        notes = letters.split.map { |name| Note[name] }
        NoteSet[*notes].num_letters.should == expected
      end
    end

    [
      [ 0, ''                    ],
      [ 1, 'A'                   ],
      [ 1, 'A A#'                ],
      [ 2, 'A B'                 ],
      [ 2, 'A A# B'              ],
      [ 7, 'C Db Eb E F# G A Bb' ],
    ].each do |expected, letters|
      include_examples "letter set", expected, letters
    end
  end

  describe "#octave_squash" do
    let(:notes) { 'Db Eb E F#'.split.map { |name| Note[name] } }
    let(:set)   { NoteSet[*notes] }

    it "should have the right octaves" do
      set.octave_squash.map(&:octave).should == [ 4, 4, 4, 4 ]
    end
  end

  describe "#octave_shift!" do
    let(:notes) { 'B7 A2 Db4 Eb3 E5 F#5'.split.map { |name| Note[name] } }
    let(:set)   { NoteSet[*notes] }

    it "should shift all notes an octave up" do
      set.octave_shift!(1).map(&:octave).should == [ 8, 3, 5, 4, 6, 6 ]
    end

    it "should shift all notes down two octaves" do
      set.octave_shift!(-2).map(&:octave).should == [ 5, 0, 2, 1, 3, 3 ]
    end
  end

  describe "#min and #max" do
    let(:notes) { 'Db4 A2 B#1 Eb3 B7 Cb7 C1 E5 F#5'.split.map { |name| Note[name] } }
    let(:set)   { NoteSet[*notes] }

    it "should work with #min" do
      set.min.name_with_octave.should == 'B#1'
    end

    it "should work with #max" do
      set.max.name_with_octave.should == 'Cb7'
    end
  end

  describe "#centre_on_clef" do
    [
      [ "treble", "B4", "B4" ],
      [ "treble", "A4", "A4" ],
      [ "treble", "D5", "D5" ],
      [ "treble", "E5", "E5" ],
      [ "treble", "F5", "F4" ],
      [ "treble", "E4", "E5" ],
      [ "treble", "D4", "D5" ],

      [ "treble", "C4 A4",   "C4 A4"   ],
      [ "treble", "A4 C4",   "A4 C4"   ],
      [ "treble", "B#4 B#5", "B#4 B#5" ],
      [ "treble", "B#4 A4",  "B#5 A5"  ],

      [ "bass",   "B3 C#3",  "B3 C#3"  ],
      [ "bass",   "Eb3 B3",  "Eb3 B3"  ],
      [ "bass",   "F3 B3",   "F3 B3"   ],
      [ "bass",   "G3 Bb3",  "G2 Bb2"  ],

      [ "bass",   "G3 F3 Bb3",  "G3 F3 Bb3" ],
    ].each do |clef, names, expected|
      it "should centre #{names} on #{clef} clef" do
        notes = names.split.map { |name| Note[name] }
        set = NoteSet[*notes]
        set.centre_on_clef(Clef[clef])
        set.to_a.join(' ').should == expected
      end
    end
  end

  describe "#to_ly_abs" do
    shared_examples "chord" do |note_names, expected|
      context note_names do
        let(:notes) { note_names.split.map { |name| Note[name] } }
        let(:chord) { NoteSet[*notes] }

        it "should convert a chord to LilyPond format" do
          chord.to_ly_abs.should == expected
        end
      end
    end

    [
      [ "C Eb G"   ,     "c' ef' g'"     ],
      [ "C E  Eb G",     "c' e'! ef' g'" ],
      [ "C Eb E G" ,     "c' ef' e'! g'" ],
    ].each do |data|
      include_examples "chord", *data
    end
  end
end
