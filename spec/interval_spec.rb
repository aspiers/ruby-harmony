require 'interval'
require 'note'

describe Interval do
  INTERVALS = [
    [  1,  0,  "1", "C" , "F#", "Gb"  ],
    [  1, +1, "#1", "C#", "Fx", "G"   ],

    [  2, -1, "b2", "Db", "G" , "Abb" ],
    [  2,  0,  "2", "D" , "G#", "Ab"  ],
    [  2, +1, "#2", "D#", "Gx", "A"   ],

    [  3, -1, "b3", "Eb", "A" , "Bbb" ],
    [  3,  0,  "3", "E" , "A#", "Bb"  ],

    [  4,  0,  "4", "F" , "B" , "Cb"  ],
    [  4, +1, "#4", "F#", "B#", "C"   ],

    [  5, -1, "b5", "Gb", "C" , "Dbb" ],
    [  5,  0,  "5", "G" , "C#", "Db"  ],
    [  5, +1, "#5", "G#", "Cx", "D"   ],

    [  6, -1, "b6", "Ab", "D" , "Ebb" ],
    [  6,  0,  "6", "A" , "D#", "Eb"  ],
    [  6, +1, "#6", "A#", "Dx", "E"   ],

    [  7, -1, "b7", "Bb", "E" , "Fb"  ],
    [  7,  0,  "7", "B" , "E#", "F"   ],
  ]

  shared_examples "an interval" do |degree, accidental, name, e1, e2, e3|
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
end
