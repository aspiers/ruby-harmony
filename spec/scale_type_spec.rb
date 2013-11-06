require 'mode'
require 'diatonic_scale_type'
require 'pentatonic_scale_type'
require 'symmetrical_scale_type'

describe ScaleType do
  describe ".all" do
    it "should be prepopulated with the catalogue" do
      ScaleType.all.size.should == 12
    end

    specify "catalogue should contain the right things" do
      ScaleType.all.map(&:name).sort.should == [
        'augmented',
        'diminished',
        'harm maj',
        'harm min',
        'maj',
        'major b2 pentatonic',
        'major b6 pentatonic',
        'major pentatonic',
        'mel min',
        'minor 6 pentatonic',
        'whole tone',
        'whole tone pentatonic',
      ]
    end

    it "should have the right index for sorting" do
      ScaleType.all.each_with_index do |st, i|
        st.index.should == i
      end
    end
  end

  describe ".all_in_subclass" do
    it "should have diatonic scales in the right order" do
      DiatonicScaleType.all_in_subclass.should == [
        DiatonicScaleType::MAJOR,
        DiatonicScaleType::MELODIC_MINOR,
        DiatonicScaleType::HARMONIC_MINOR,
        DiatonicScaleType::HARMONIC_MAJOR,
      ]
    end

    it "should have symmetrical scales in the right order" do
      SymmetricalScaleType.all_in_subclass.should == [
        SymmetricalScaleType::WHOLE_TONE,
        SymmetricalScaleType::DIMINISHED,
        SymmetricalScaleType::AUGMENTED,
      ]
    end
  end

  describe "#degree_of" do
    [
      [ DiatonicScaleType::MAJOR,         'Bb', 'Bb', 1 ],
      [ DiatonicScaleType::MELODIC_MINOR, 'C',  'B',  7 ],
      [ SymmetricalScaleType::DIMINISHED, 'C',  'G#', 6 ],
    ].each do |scale_type, key_name, note_name, expected_degree|
      context "#{key_name} #{scale_type}" do
        it "should return the right degree for #{note_name}" do
          scale_type.degree_of(Note[note_name], Note[key_name]).should == expected_degree
        end
      end
    end
  end
end

