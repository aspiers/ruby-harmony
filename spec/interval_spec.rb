require 'interval'
require 'note'

describe Interval do
  INTERVALS = [
    # test data for intervals, starting from three different notes:
    # C0 (e1/o1 columns), F#2 (e2/o2 columns), and Gb5 (e3/o3 columns)
    #deg acc   name   e1  o1   e2  o2   e3   o3   long_name
    [  1,  0,   "1", "C" , 0, "F#", 2, "Gb" , 5, "unison"           ],
    [  1, +1,  "#1", "C#", 0, "Fx", 2, "G"  , 5, "aug unison"       ],

    [  2, -1,  "b2", "Db", 0, "G" , 2, "Abb", 5, "minor 2nd"        ],
    [  2,  0,   "2", "D" , 0, "G#", 2, "Ab" , 5, "major 2nd"        ],
    [  2, +1,  "#2", "D#", 0, "Gx", 2, "A"  , 5, "aug 2nd"          ],

    [  3, -1,  "b3", "Eb", 0, "A" , 2, "Bbb", 5, "minor 3rd"        ],
    [  3,  0,   "3", "E" , 0, "A#", 2, "Bb" , 5, "major 3rd"        ],

    [  4,  0,   "4", "F" , 0, "B" , 2, "Cb" , 5, "perfect 4th"      ],
    [  4, +1,  "#4", "F#", 0, "B#", 3, "C"  , 6, "aug 4th"          ],

    [  5, -1,  "b5", "Gb", 0, "C" , 3, "Dbb", 6, "dim 5th"          ],
    [  5,  0,   "5", "G" , 0, "C#", 3, "Db" , 6, "perfect 5th"      ],
    [  5, +1,  "#5", "G#", 0, "Cx", 3, "D"  , 6, "aug 5th"          ],

    [  6, -1,  "b6", "Ab", 0, "D" , 3, "Ebb", 6, "minor 6th"        ],
    [  6,  0,   "6", "A" , 0, "D#", 3, "Eb" , 6, "major 6th"        ],
    [  6, +1,  "#6", "A#", 0, "Dx", 3, "E"  , 6, "aug 6th"          ],

    [  7, -1,  "b7", "Bb", 0, "E" , 3, "Fb" , 6, "minor 7th"        ],
    [  7,  0,   "7", "B" , 0, "E#", 3, "F"  , 6, "major 7th"        ],

    [  9, -1,  "b9", "Db", 1, "G" , 3, "Abb", 6, "flat 9th"         ],
    [  9,  0,   "9", "D" , 1, "G#", 3, "Ab" , 6, "major 9th"        ],
    [  9,  1,  "#9", "D#", 1, "Gx", 3, "A"  , 6, "aug 9th"          ],

    [ 11,  0,  "11", "F" , 1, "B" , 3, "Cb" , 6, "perfect 11th"     ],
    [ 11,  1, "#11", "F#", 1, "B#", 4, "C"  , 7, "sharp 11th"       ],

    [ 13, -1, "b13", "Ab", 1, "D" , 4, "Ebb", 7, "flat 13th"        ],
  ]

  describe ".by_name and .[]" do
    it "should raise an exception when passed an invalid interval" do
      expect { Interval.by_name('blah') }.to raise_exception "Invalid interval 'blah'"
    end

    it "should raise an exception when passed an invalid interval" do
      expect { Interval['blah'] }.to raise_exception "Invalid interval 'blah'"
    end
  end

  shared_examples "an interval" do
    |degree, accidental, name, e1, o1, e2, o2, e3, o3, long_name|

    let(:interval) { Interval.new(degree, accidental) }
    let(:c)        { Note.by_name('C0' )              }
    let(:f_sharp)  { Note.by_name('F#2')              }
    let(:g_flat)   { Note.by_name('Gb5')              }

    it "should have degree #{degree}" do
      interval.degree.should == degree
    end

    it "should have accidental #{accidental}" do
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

    it "should have the right (short) name" do
      interval.name.should == name
    end

    it "should stringify to its short name" do
      interval.to_s.should == name
    end

    it "should have the right (long) name" do
      interval.long_name.should == long_name
    end

    it "should have the right adjective" do
      words = long_name.split
      if words.size == 2 and degree < 9
        words[0].should == interval.adjective
      end
    end

    it "should be constructable #by_name" do
      Interval.by_name(name).name.should == name
    end

    it "should be constructable by .[]" do
      Interval[name].name.should == name
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
