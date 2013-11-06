require 'scale_type'
require 'scale_speller'

class PentatonicScaleType < ScaleType
  include ScaleSpeller

  def initialize(name, increments, degrees=nil)
    @degrees = degrees || [ 1, 2, 3, 5, 6 ]
    super(name, increments, 5, 12)
  end

  def letter_shift(degree)
    @degrees[degree - 1] - 1
  end

  def equivalent_keys(key_note)
    Note.by_pitch(key_note.pitch)
  end

  MAJOR      = new('major pentatonic',      [ 2, 2, 3, 2, 3 ])
  # Jerry Bergonzi volume 2 chapter 9
  MINOR_SIX  = new('minor 6 pentatonic',    [ 2, 1, 4, 2, 3 ])
  FLAT_SIX   = new('major b6 pentatonic',   [ 2, 2, 3, 1, 4 ])
  FLAT_TWO   = new('major b2 pentatonic',   [ 1, 3, 3, 2, 3 ])
  WHOLE_TONE = new('whole tone pentatonic', [ 4, 2, 2, 2, 2 ], [ 1, 3, 4, 6, 7 ])

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

  class << MINOR_SIX
    def mode_name(degree)
      case degree
      when 5
        # Jerry Bergonzi volume 2 chapter 9
        "minor 7b5 pentatonic"
      else
        super
      end
    end
  end

  # class << WHOLE_TONE
  #   def note(key_note, degree)
  #     n = super(key_note, degree)
  #     degree == 5 ? n.simplify : n
  #   end
  # end
end
