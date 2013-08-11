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

  describe "lookup by name" do
    shared_examples "name" do |name|
      specify ".by_name should return the right chord type" do
        ChordType.by_name(name).name == name
      end

      specify "[] should return the right chord type" do
        ChordType[name].name == name
      end
    end

    %w(maj7 min9 dim).each do |name|
      include_examples "name", name
    end
  end

  describe "getting intervals" do
    shared_examples "chord" do |chord_type, expected|
      specify "via ChordType.get_intervals" do
        intervals = ChordType.get_intervals(chord_type)
        intervals.join(' ').should == expected
      end

      specify "via ChordType#intervals" do
        intervals = ChordType[chord_type].intervals
        intervals.join(' ').should == expected
      end
    end

    include_examples 'chord', 'maj7',   '3 5 7'
    include_examples 'chord', '7b9#11', '3 b7 b9 #11'
  end
end
