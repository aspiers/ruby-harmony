require 'mode'

describe ScaleInKey do
  [
    [ 2, "C", DiatonicScaleType::MAJOR,         "C dorian\n(2nd degree of C maj)"      ],
    [ 6, "F", DiatonicScaleType::MAJOR,         "F aeolian\n(6th degree of F maj)"     ],
    [ 6, "F", DiatonicScaleType::MELODIC_MINOR, "F locrian natural 2\n(6th degree of F mel min)" ],
  ].each do |degree, key_name, scale_type, expected_name|
    it "should have the right name" do
      ScaleInKey.new(Mode.new(degree, scale_type, 0), Note.by_name(key_name)).name.should == expected_name
    end
  end
end
