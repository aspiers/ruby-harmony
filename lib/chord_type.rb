require 'interval'

class ChordType
  PRESETS = [
    [ 'maj'         , '   3    5                      ' ],
    [ 'maj7'        , '   3          7                ' ],
    [ 'maj9'        , '   3          7  9             ' ],
    [ 'maj7#11'     , '   3          7       #11      ' ],
    [ 'maj7#5'      , '   3   #5     7                ' ],
    [ 'maj7#9'      , '   3          7    #9          ' ],
    [ 'maj7#5#9'    , '   3   #5     7    #9          ' ],

    [ '6'           , '   3       6                   ' ],
    [ '6 9'         , '   3       6     9             ' ],

    [ 'min'         , '  b3    5                      ' ],
    [ 'min7'        , '  b3         b7                ' ],
    [ 'min7b5'      , '  b3   b5    b7                ' ],
    [ 'min7b9'      , '  b3         b7 b9             ' ],
    [ 'min7b5b9'    , '  b3   b5    b7 b9             ' ],
    [ 'min9'        , '  b3         b7  9             ' ],
    [ 'min9b5'      , '  b3   b5    b7  9             ' ],
    [ 'min11'       , '  b3         b7  9     11      ' ],
    [ 'min11b5'     , '  b3   b5    b7  9     11      ' ],
    [ 'min11b9'     , '  b3         b7 b9     11      ' ],
    [ 'min11b5b9'   , '  b3   b5    b7 b9     11      ' ],

    [ 'min6'        , '  b3       6                   ' ],
    [ 'min6 9'      , '  b3       6     9             ' ],

    [ 'min/maj7'    , '  b3          7                ' ],

    [ '7'           , '   3         b7                ' ],
    [ '7#11'        , '   3         b7       #11      ' ],
    [ '7b13'        , '   3         b7           b13  ' ],
    [ '7#11b13'     , '   3         b7       #11 b13  ' ],

    [ '7b9'         , '   3         b7 b9             ' ],
    [ '7b9#11'      , '   3         b7 b9    #11      ' ],
    [ '7b9b13'      , '   3         b7 b9        b13  ' ],
    [ '7b9#11b13'   , '   3         b7 b9    #11 b13  ' ],
    [ '13b9'        , '   3         b7 b9         13  ' ],
    [ '13b9#11'     , '   3         b7 b9    #11  13  ' ],

    [ '9'           , '   3         b7  9             ' ],
    [ '9#11'        , '   3         b7  9    #11      ' ],
    [ '9b13'        , '   3         b7  9        b13  ' ],
    [ '9#11b13'     , '   3         b7  9    #11 b13  ' ],
    [ '13'          , '   3         b7  9         13  ' ],
    [ '13#11'       , '   3         b7  9    #11  13  ' ],

    [ '7#9'         , '   3         b7    #9          ' ],
    [ '7#9#11'      , '   3         b7    #9 #11      ' ],
    [ '7#9b13'      , '   3         b7    #9     b13  ' ],
    [ '7#9#11b13'   , '   3         b7    #9 #11 b13  ' ],
    [ '13b9'        , '   3         b7 b9         13  ' ],
    [ '13b9#11'     , '   3         b7 b9    #11  13  ' ],

    [ '7b9#9'       , '   3         b7 b9 #9          ' ],
    [ '7b9#9#11'    , '   3         b7 b9 #9 #11      ' ],
    [ '7b9#9b13'    , '   3         b7 b9 #9     b13  ' ],
    [ '7b9#9#11b13' , '   3         b7 b9 #9 #11 b13  ' ],
    [ '13b9#9'      , '   3         b7 b9 #9      13  ' ],
    [ '13b9#9#11'   , '   3         b7 b9 #9 #11  13  ' ],

    [ 'sus4'        , '     4                         ' ],
    [ 'sus4add2'    , ' 2   4                         ' ],

    [ '7sus4'       , '     4       b7                ' ],
    [ '7b13sus4'    , '     4       b7           b13  ' ],

    [ '7b9sus4'     , '     4       b7 b9             ' ],
    [ '7b9b13sus4'  , '     4       b7 b9        b13  ' ],
    [ '13b9sus4'    , '     4       b7 b9         13  ' ],

    [ '9sus4'       , '     4       b7  9             ' ],
    [ '9b13sus4'    , '     4       b7  9        b13  ' ],
    [ '13sus4'      , '     4       b7  9         13  ' ],

    [ '13b9sus4'    , '     4       b7 b9         13  ' ],

    [ 'dim'         , 'b3     b5                      ' ],
    [ 'dim7'        , 'b3     b5  6                   ' ],
  ]

  @@names = [ ]
  @@all   = { }

  attr_accessor :name, :intervals, :index

  def initialize(name, intervals)
    self.name = name
    self.intervals = intervals
    @index = @@names.length

    @@all[name] = self
    @@names.push name
  end

  def ChordType.names
    @@names
  end

  def ChordType.by_name(name)
    @@all[name]
  end

  class << self
    alias_method :[], :by_name
  end

  def notes(key)
    arr = [key] + intervals.map do |interval|
      note = interval.from(key)
      note.octave -= 1 if %w(#11 b13).include? interval.name
      note
    end
    NoteArray[*arr]
  end

  def modified_fifth?
    ! (intervals.map(&:name) & %w(5 b5 #5 #11 b13)).empty?
  end

  def maybe_add_fifth
    return self if modified_fifth?
    self.class.new(name + ' (with 5th)', (intervals + [ Interval['5'] ]).sort)
  end

  private
  def ChordType.load_presets
    for preset in PRESETS
      name, interval_names = preset
      interval_names = interval_names.strip.split
      new(name, interval_names.map { |name| Interval.by_name(name) })
    end
  end

  ChordType.load_presets
end
