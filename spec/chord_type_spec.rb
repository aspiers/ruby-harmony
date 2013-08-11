require 'chord_type'

describe ChordType do
  describe "#names" do
    let(:names) { ChordType.names }

    it "should have a lot of names" do
      names.size.should >= 30
    end

    it "should contain strings" do
      names[rand(names.size)].is_a?(String).should be_true
    end
  end

  describe "#get_intervals" do
    shared_examples "chord" do |chord_type, expected|
      it "should contain the right notes" do
        intervals = ChordType.get_intervals(chord_type)
        intervals.join(' ').should == expected
      end
    end

    include_examples "chord", "maj7",   "3 5 7"
    include_examples "chord", "7b9#11", "3 b7 b9 #11"
  end
end
