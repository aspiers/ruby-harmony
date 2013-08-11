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
end
