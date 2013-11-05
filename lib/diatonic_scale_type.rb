require 'scale_type'

class DiatonicScaleType < ScaleType
  def initialize(name, increments)
    super(name, increments, 7, 12)
  end

  def offset_from_key(degree)
    # concatenate as many increments together as we need
    # to reach the degree, which may be greater than the
    # number of notes in the scale (e.g. 11, 13)
    incs = increments * (1 + (degree - 1) / num_modes)
    increments_from_key = incs.first(degree - 1)
    return increments_from_key.inject(0) { |a,x| a + x }
  end

  MAJOR           = new('maj',             [ 2, 2, 1, 2, 2, 2, 1 ])
  MELODIC_MINOR   = new('mel min',         [ 2, 1, 2, 2, 2, 2, 1 ])
  HARMONIC_MINOR  = new('harm min',        [ 2, 1, 2, 2, 1, 3, 1 ])
  HARMONIC_MAJOR  = new('harm maj',        [ 2, 2, 1, 2, 1, 3, 1 ])
  # HUNGARIAN_GYPSY = new('hungarian gypsy', [ 2, 1, 3, 1, 1, 2, 2 ])
  # DOUBLE_HARMONIC = new('dbl harm',        [ 1, 3, 1, 2, 1, 3, 1 ])
  # ENIGMATIC       = new('enigmatic',       [ 1, 3, 2, 2, 2, 2, 2 ])

  class << MAJOR
  #DEGREES = %w(ion dor phryg lyd mixo aeol loc)
  DEGREES = %w(ionian dorian phrygian lydian mixo aeolian locrian)
  #DEGREES = %w(ionian dorian phrygian lydian mixolydian aeolian locrian)

    def mode_name(degree)
      DEGREES[degree - 1]
    end
  end

  class << MELODIC_MINOR
    def mode_name(degree)
      case degree
      when 2
        "dorian b2"
      when 3
        "lydian augmented"
      when 4
        "lydian dominant"
      when 5
        "dominant b13"
      when 6
        "locrian natural 2"
      when 7
        "altered"
      else
        super
      end
    end
  end

  class << HARMONIC_MINOR
    def mode_name(degree)
      case degree
      when 2
        "locrian natural 6"
      when 3
        "major #5"
      when 4
        # "dorian / lydian"
        "dorian #4"
      when 5
        "dominant b9 b13"
      when 6
        "lydian #2"
      else
        super
      end
    end
  end

  class << HARMONIC_MAJOR
    def mode_name(degree)
      case degree
      when 4
        # "lydian mel min"
        "melodic min #4"
      when 5
        "dominant b9"
      when 6
        "lydian #2 #5"
      else
        super
      end
    end
  end
end

