require 'accidental'

describe Accidental do
  describe "#to_ly_markup" do
    it "should convert flat notes" do
      Accidental.to_ly_markup('"Absolutely Ab and Bb major"').should ==
        '"Absolutely A"\raise #0.5 \fontsize #-3 \flat " and B"\raise #0.5 \fontsize #-3 \flat " major"'
    end

    it "should convert sharp notes" do
      Accidental.to_ly_markup('"F# and C# major"').should ==
        '"F"\raise #0.5 \fontsize #-3 \sharp " and C"\raise #0.5 \fontsize #-3 \sharp " major"'
    end

    it "should convert flat numbers" do
      Accidental.to_ly_markup('"minor 7 is b3 and b7"').should ==
        '"minor 7 is "\raise #0.5 \fontsize #-3 \flat "3 and "\raise #0.5 \fontsize #-3 \flat "7"'
    end

    it "should convert flat numbers inside chord names" do
      Accidental.to_ly_markup('"min7b5"').should ==
        '"min7"\raise #0.5 \fontsize #-3 \flat "5"'
    end

    it "should convert sharp numbers" do
      Accidental.to_ly_markup('"lydian has #11"').should ==
        '"lydian has "\raise #0.5 \fontsize #-3 \sharp "11"'
    end

    it "should convert natural numbers" do
      Accidental.to_ly_markup('"lydian has natural 3"').should ==
        '"lydian has "\raise #0.5 \fontsize #-3 \natural "3"'
    end
  end
end
