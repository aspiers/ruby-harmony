require 'accidental'

# A class representing notes which have a numerical
# pitch (not constrained to a single octave), and a
# name (i.e. "F#" is considered distinct from "Gb").
class Note
  # An Array of note letters, starting with C.
  LETTERS = %w(C D E F G A B)

  # The numerical pitches corresponding to LETTERS, starting
  # with C at 0.
  NATURAL_PITCHES = [ 0, 2, 4, 5, 7, 9, 11 ]

  def initialize(letter, accidental, pitch)
    @letter = letter
    @accidental = accidental
    @pitch = pitch
  end

  # An Array of Note instances corresponding to the C major scale.
  NATURALS = LETTERS.zip(NATURAL_PITCHES).map { |l, p| new(l, 0, p) }

  attr_accessor :letter, :accidental, :pitch

  # Instantiates a Note with the given letter and pitch.
  def Note.by_letter_and_pitch(letter, pitch)
    natural = NATURALS.find { |n| n.letter == letter }
    raise "no such note with letter '#{letter}'" unless natural
    delta = pitch - natural.pitch
    delta += 12 while delta < -6
    delta -= 12 while delta >  6

    if (delta.abs) > 2
      raise "pitch mismatch for letter '#{letter}' and pitch #{pitch} (natural #{natural.pitch}, delta #{delta})"
    end
    new(letter, delta, pitch)
  end

  # Instantiates a Note with the given letter in the C major scale.
  def Note.by_letter(letter)
    NATURALS.find { |n| n.letter == letter }
  end

  # Shifts a note letter up the C major scale by the given number of
  # steps, and returns the resulting letter (*not* a Note instance).
  # For example, shifting C by 3 steps results in F, and shifting A by
  # 4 steps results in E.
  def Note.letter_shift(letter, steps)
    index = LETTERS.find_index { |l| l == letter }
    raise "no such letter '#{letter}'" unless index
    return LETTERS[(index + steps) % LETTERS.length]
  end

  # Instantiate a note by a string representing its name, e.g. "C#".
  def Note.by_name(n)
    letter = n[0]
    accidental_label = n[1..-1]
    accidental_delta = Accidental::DELTAS[accidental_label]
    raise "unrecognised accidental '#{accidental_label}'" unless accidental_delta

    natural = by_letter(letter)
    pitch = (natural.pitch + accidental_delta) % 12
    new(letter, accidental_delta, pitch)
  end

  # Convert a double-sharp or double-flat into its simpler enharmonic
  # equivalent.
  def simplify
    return self if accidental.abs < 2
    direction = accidental / accidental.abs
    new_letter = Note.letter_shift(letter, direction)
    new_accidental = accidental - direction*2
    Note.new(new_letter, new_accidental, pitch)
  end

  # Return a String representation of the Note's name.
  def name
    letter + Accidental::LABELS[accidental]
  end

  alias_method :to_s, :name

  # Return a LilyPond representation of the Note's name to be used
  # in a \relative context.
  def to_ly
    letter.downcase + Accidental::LY[accidental]
  end

  def octave
    pitch / 12
  end

  # Return a LilyPond representation of the Note's name to be used
  # in an absolute pitch context.
  def to_ly_abs
    letter.downcase + Accidental::LY[accidental] +
      (octave < -1 ? "," * (-octave - 1) : "'" * (octave + 1))
  end

  # Return a LilyPond representation of the Note's name for use within \markup.
  def to_ly_markup
    letter + Accidental::LY_MARKUP[accidental]
  end

  def inspect
    "%-2s" % to_s
  end

  # Order notes by pitch.
  def <=>(other)
    pitch <=> other.pitch
  end

  def ==(other)
    letter == other.letter and pitch == other.pitch and accidental == other.accidental
  end

  # Returns true if the notes have the same pitch when transposed to
  # within a single octave.
  def equivalent?(other)
    pitch % 12 == other.pitch % 12
  end

  alias_method :===, :equivalent?
end

