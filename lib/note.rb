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

  attr_reader   :letter
  attr_accessor :accidental, :pitch

  def initialize(l, a, p)
    Note.letter_pitch_delta(l, p)
    self.letter = l
    self.accidental = a
    self.pitch = p
  end

  def letter=(l)
    raise "no such note with letter '#{l}'" unless LETTERS.include? l
    @letter = l
  end

  # An Array of Note instances corresponding to the C major scale.
  NATURALS = Hash[LETTERS.zip(NATURAL_PITCHES)]

  def Note.letter_pitch_delta(letter, pitch)
    natural_pitch = NATURALS[letter]
    raise "no such note with letter '#{letter}'" unless natural_pitch
    delta = pitch - natural_pitch
    delta += 12 while delta < -6
    delta -= 12 while delta >  6
    if (delta.abs) > 2
      raise "pitch mismatch for letter '#{letter}' and pitch #{pitch} (natural #{natural_pitch}, delta #{delta})"
    end
    return delta
  end

  # Instantiates a Note with the given letter and pitch.
  def Note.by_letter_and_pitch(letter, pitch)
    delta = Note.letter_pitch_delta(letter, pitch)
    new(letter, delta, pitch)
  end

  # Instantiates a Note with the given letter in the C major scale.
  def Note.by_letter(letter)
    natural_pitch = NATURALS[letter]
    raise "no such note with letter '#{letter}'" unless natural_pitch
    new(letter, 0, natural_pitch)
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

  def octave=(o)
    return if octave == o
    self.pitch = o*12 + pitch % 12
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

  include Comparable

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

