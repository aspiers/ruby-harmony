# -*- coding: utf-8 -*-
require 'scale_type'

class DiatonicScaleType < ScaleType
  attr_accessor :mode_names

  def initialize(name, increments)
    super(name, increments, 7, 12)
  end

  MAJOR           = new('maj',             [ 2, 2, 1, 2, 2, 2, 1 ])
  MELODIC_MINOR   = new('mel min',         [ 2, 1, 2, 2, 2, 2, 1 ])
  HARMONIC_MINOR  = new('harm min',        [ 2, 1, 2, 2, 1, 3, 1 ])
  HARMONIC_MAJOR  = new('harm maj',        [ 2, 2, 1, 2, 1, 3, 1 ])
  # HUNGARIAN_GYPSY = new('hungarian gypsy', [ 2, 1, 3, 1, 1, 2, 2 ])
  # DOUBLE_HARMONIC = new('dbl harm',        [ 1, 3, 1, 2, 1, 3, 1 ])
  # ENIGMATIC       = new('enigmatic',       [ 1, 3, 2, 2, 2, 2, 2 ])

  def mode_name(degree)
    mode_names[degree - 1]
  end

  #MAJOR.mode_names = %w(ion dor phryg lyd mixo aeol loc)
  MAJOR.mode_names = %w(ionian dorian phrygian lydian mixo aeolian locrian)
  #MAJOR.mode_names = %w(ionian dorian phrygian lydian mixolydian aeolian locrian)

  # See the scalematcher FAQ for the reasons behind these choices of mode names.
  MELODIC_MINOR.mode_names = [
    nil,                     # 1
    "dorian b9",             # 2
    # "dorian b2",             # 2
    # "phrygian ♮6",           # 2
    "lydian augmented",      # 3
    "lydian mixolydian",     # 4
    # "lydian dominant",       # 4
    # "lydian b7",             # 4
    "mixolydian b13",        # 5
    # "dominant b13",          # 5
    # "mixolydian b6",         # 5
    "locrian ♮9",            # 6
    "altered",               # 7
  ]
  HARMONIC_MINOR.mode_names = [
    nil,                     # 1
    "locrian ♮6",            # 2
    "ionian #5",             # 3
    # "major #5",              # 3
    # "ionian augmented",      # 3
    # "dorian / lydian",       # 4
    "dorian #11",            # 4
    # "dorian #4",             # 4
    "mixolydian b9 b13",     # 5
    # "phrygian mixolydian",   # 5
    # "phrygian dominant",     # 5
    # "dominant b9 b13",       # 5
    "lydian #9",             # 6
    # "lydian #2",             # 6
    "altered bb7",           # 7
  ]
  HARMONIC_MAJOR.mode_names = [
    nil,                     # 1
    "locrian ♮9 ♮13",        # 2
    # "locrian ♮2 ♮6",        # 2
    "altered ♮5",            # 3
    "melodic min #11",       # 4
    # "melodic min #4",        # 4
    # "lydian mel min",        # 4
    "mixolydian b9",         # 5
    # "dominant b9",           # 5
    "lydian augmented #9",   # 6
    # "lydian augmented #2",   # 6
    # "lydian #9 b13",         # 6
    # "lydian #2 #5",          # 6
    "locrian bb7",           # 7
  ]
end

