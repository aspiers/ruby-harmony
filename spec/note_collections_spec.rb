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
      set.octave_squash.map(&:octave).should == [ 0, 0, 0, 0 ]
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
