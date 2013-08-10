require 'interval'
require 'note'

describe Interval do
  INTERVALS = [
    [  1,  0,  "1", "C" , 0, "F#", 0, "Gb" , 0 ],
    [  1, +1, "#1", "C#", 0, "Fx", 0, "G"  , 0 ],

    [  2, -1, "b2", "Db", 0, "G" , 0, "Abb", 0 ],
    [  2,  0,  "2", "D" , 0, "G#", 0, "Ab" , 0 ],
    [  2, +1, "#2", "D#", 0, "Gx", 0, "A"  , 0 ],

    [  3, -1, "b3", "Eb", 0, "A" , 0, "Bbb", 0 ],
    [  3,  0,  "3", "E" , 0, "A#", 0, "Bb" , 0 ],

    [  4,  0,  "4", "F" , 0, "B" , 0, "Cb" , 0 ],
    [  4, +1, "#4", "F#", 0, "B#", 1, "C"  , 1 ],

    [  5, -1, "b5", "Gb", 0, "C" , 1, "Dbb", 1 ],
    [  5,  0,  "5", "G" , 0, "C#", 1, "Db" , 1 ],
    [  5, +1, "#5", "G#", 0, "Cx", 1, "D"  , 1 ],

    [  6, -1, "b6", "Ab", 0, "D" , 1, "Ebb", 1 ],
    [  6,  0,  "6", "A" , 0, "D#", 1, "Eb" , 1 ],
    [  6, +1, "#6", "A#", 0, "Dx", 1, "E"  , 1 ],

    [  7, -1, "b7", "Bb", 0, "E" , 1, "Fb" , 1 ],
    [  7,  0,  "7", "B" , 0, "E#", 1, "F"  , 1 ],

    [  9, -1, "b9", "Db", 1, "G" , 1, "Abb", 1 ],
    [  9,  0,  "9", "D" , 1, "G#", 1, "Ab" , 1 ],
    [  9,  1, "#9", "D#", 1, "Gx", 1, "A"  , 1 ],

    [ 11,  0, "11", "F" , 1, "B" , 1, "Cb" , 1 ],
    [ 11,  1,"#11", "F#", 1, "B#", 2, "C"  , 2 ],

    [ 13, -1,"b13", "Ab", 1, "D" , 2, "Ebb", 2 ],

  ]

  shared_examples "an interval" do |degree, accidental, name, e1, o1, e2, o2, e3, o3|
    let(:interval) { Interval.new(degree, accidental) }
    let(:c)        { Note.by_name('C')                }
    let(:f_sharp)  { Note.by_name('F#')               }
    let(:g_flat)   { Note.by_name('Gb')               }

    it "should have the right degree" do
      interval.degree.should == degree
    end

    it "should have the right accidental" do
      interval.accidental.should == accidental
    end

    it "should have the right note relative to C" do
      interval.from(c).name.should == e1
    end

    it "should have the right note relative to F#" do
      interval.from(f_sharp).name.should == e2
    end

    it "should have the right note relative to Gb" do
      interval.from(g_flat).name.should == e3
    end

    it "#{degree} should have octave #{o1} relative to C" do
      interval.from(c).octave.should == o1
    end

    it "#{degree} should have octave #{o2} relative to F#" do
      interval.from(f_sharp).octave.should == o2
    end

    it "#{degree} should have octave #{o3} relative to Gb" do
      interval.from(g_flat).octave.should == o3
    end

    it "should have the right name" do
      interval.name.should == name
    end

    it "should be constructable by name" do
      Interval.by_name(name).name.should == name
    end
  end

  INTERVALS.each do |data|
    it_should_behave_like "an interval", *data
  end

  it "should sort intuitively" do
    intervals = INTERVALS.map do |degree, accidental, *rest|
      Interval.new(degree, accidental)
    end
    intervals.sort.should == intervals
  end
end
