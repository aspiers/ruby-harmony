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

    include_examples 'chord notes', 'C', 'maj7',   'C E B'
    include_examples 'chord notes', 'D', 'min9',   'D F C E'
    include_examples 'chord notes', 'E', '7b9#11', 'E G# D F A#'
  end
end
