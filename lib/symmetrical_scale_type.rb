require 'scale_speller'

class SymmetricalScaleType < ScaleType
  include ScaleSpeller

  WHOLE_TONE      = new('whole tone',      [ 2, 2, 2, 2, 2, 2             ], 1,  2)
  DIMINISHED      = new('diminished',      [ 2, 1, 2, 1, 2, 1, 2, 1       ], 2,  3)
  AUGMENTED       = new('augmented',       [ 3, 1, 3, 1, 3, 1             ], 2,  4)
  # MESSIAEN_THREE    = new("Messian's 3rd", [ 2, 1, 1, 2, 1, 1, 2, 1, 1    ], 3, 4)
  # MESSIAEN_FOURTH   = new("Messian's 4th", [ 1, 1, 3, 1, 1, 1, 3, 1       ], 3, 4)
  # MESSIAEN_FIFTH    = new("Messian's 5th", [ 1, 4, 1, 1, 4, 1             ], 3, 6)
  # MESSIAEN_SIXTH    = new("Messian's 6th", [ 2, 2, 2, 1, 2, 2, 2, 1       ], 4, 6)
  # MESSIAEN_SEVENTH  = new("Messian's 7th", [ 1, 1, 1, 2, 1, 1, 1, 1, 2, 1 ], 5, 6)

  class << DIMINISHED
    def letter_shift(degree)
      steps_from_key = (degree - 1) % 7
      return steps_from_key - 1 if degree >= 7
      return steps_from_key
    end

    # Return the note which is the given degree of the scale.
    def note(key_note, degree)
      super(key_note, degree).simplify
    end

    def mode_name(degree)
      return degree == 2 ? 'auxiliary diminished' : nil
    end
  end

  class << WHOLE_TONE
    def mode_name(degree)
      return name
    end

    def note(key_note, degree)
      super(key_note, degree).simplify
    end
  end

  class << AUGMENTED
    def letter_shift(degree)
      steps_from_key = (degree - 1) % 7
      return steps_from_key + 1 if degree >= 4
      return steps_from_key
    end

    # def note(key_note, degree)
    #   super(key_note, degree).simplify
    # end
  end
end
