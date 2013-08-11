module NoteExceptions
  class InvalidLetter < StandardError
    def initialize(letter)
      @letter = letter
    end

    def to_s
      "No such note with letter '#{@letter}'"
    end
  end

  class LetterPitchMismatch < StandardError
    def initialize(letter, pitch, natural_pitch, delta)
      @letter = letter
      @pitch = pitch
      @natural_pitch = natural_pitch
      @delta = delta
    end

    def to_s
      "Pitch mismatch for letter '#{@letter}' and pitch #{@pitch} (natural #{@natural_pitch}, delta #{@delta})"
    end
  end
end
