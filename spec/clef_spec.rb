require 'clef'

describe Clef do
  let (:names) { %w(treble alto tenor bass) }

  it "should be populated with 4 clefs" do
    Clef.all.size.should == 4
  end

  it "should be reference-able by name" do
    names.each do |name|
      Clef.by_name(name).name.should == name
      Clef[name]        .name.should == name
    end
  end

  it "should be sorted in order of descending pitch" do
    Clef.all.sort.map(&:name).should == names
  end

  it "should have the right pitch" do
    Clef::TREBLE.centre_note.pitch.should ==  71 # B above middle C
    Clef::ALTO  .centre_note.pitch.should ==  60 #         middle C
    Clef::TENOR .centre_note.pitch.should ==  57 # A below middle C
    Clef::BASS  .centre_note.pitch.should ==  50 # D below middle C
  end
end
