require 'scale_type'

class PentatonicScaleType < ScaleType
  def initialize(name, increments)
    super(name, increments, 5, 12)
  end

  DEGREES = [ 1, 2, 3, 5, 6 ]

  def letter_shift(degree)
    DEGREES[degree - 1] - 1
  end

  MAJOR    = new('major pentatonic', [ 2, 2, 3, 2, 3 ])

  class << MAJOR
    def mode_name(degree)
      # http://en.wikipedia.org/wiki/Pentatonic#Five_black-key_pentatonic_scales_of_the_piano
      case degree
      when 2
        #"Egyptian pentatonic"
        "suspended pentatonic"
      when 3
        #"Man Gong"
        "blues minor pentatonic"
      when 4
        #"Ritusen"
        #"yo scale"
        "blues major"
      when 5
        "minor pentatonic"
      else
        super
      end
    end
  end
end
