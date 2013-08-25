require 'note'
require 'note_collections'

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
