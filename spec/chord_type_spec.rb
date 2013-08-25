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
      specify "via ChordType#intervals" do
        intervals = ChordType[chord_type].intervals
        intervals.join(' ').should == expected
      end
    end

    include_examples 'chord', 'maj7',   '3 7'
    include_examples 'chord', '7b9#11', '3 b7 b9 #11'
  end

  describe "#notes" do
    shared_examples "chord notes" do |key_name, chord_type, expected|
      it "should return the right notes" do
        key = Note.by_name(key_name)
        notes = ChordType[chord_type].notes(key)
        notes.join(' ').should == expected
      end
    end

    include_examples 'chord notes', 'C', 'maj7',   'C4 E4 B4'
    include_examples 'chord notes', 'D', 'min9',   'D4 F4 C5 E5'
    include_examples 'chord notes', 'E', '7b9#11', 'E4 G#4 D5 F5 A#5'
  end

  describe "#maybe_add_fifth" do
    it "should add a fifth" do
      ct = ChordType['min7']
      ct.intervals.should_not include(Interval['5'])
      ct.maybe_add_fifth.intervals.join(' ').should == 'b3 5 b7'
    end

    it "should not add a fifth" do
      ct = ChordType['min7b5']
      ct.maybe_add_fifth.intervals.join(' ').should == 'b3 b5 b7'
    end

    it "should not add a fifth twice" do
      ct = ChordType['min7']
      ct.maybe_add_fifth.maybe_add_fifth.intervals.join(' ').should == 'b3 5 b7'
    end
  end
end
