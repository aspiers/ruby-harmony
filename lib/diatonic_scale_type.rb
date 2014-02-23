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

  MELODIC_MINOR.mode_names = [
    nil,                  # 1
    # "phrygian natural 6", # 2
    "dorian b2",          # 2
    "lydian augmented",   # 3
    "lydian dominant",    # 4
    "dominant b13",       # 5
    "locrian natural 2",  # 6
    "altered",            # 7
  ]

  HARMONIC_MINOR.mode_names = [
    nil,                 # 1
    "locrian natural 6", # 2
    "major #5",          # 3
    # "dorian / lydian",   # 4
    "dorian #4",         # 4
    "dominant b9 b13",   # 5
    "lydian #2",         # 6
    nil,                 # 7
  ]

  HARMONIC_MAJOR.mode_names = [
    nil,                # 1
    nil,                # 2
    nil,                # 3
    # "lydian mel min",   # 4
    "melodic min #4",   # 4
    "dominant b9",      # 5
    "lydian #2 #5",     # 6
    nil,                # 7
  ]
end

