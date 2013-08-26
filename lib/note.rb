require 'accidental'
require 'exceptions'

# A class representing notes which have a numerical pitch (not
# constrained to a single octave), and a name (i.e. "F#" is considered
# distinct from "Gb").  If a note is constructed without specifying
# its octave, its pitch will default to the octave from middle C
# (i.e. C4) to the B above it (B4), using MIDI pitch numbering (C4 is
# 60).  See
#
#   http://en.wikipedia.org/wiki/Note#Note_designation_in_accordance_with_octave_name
#
# for the origin of this naming system.
class Note
  # An Array of note letters, starting with C.
  LETTERS = %w(C D E F G A B)
  STANDARD_KEY_NAMES = %w(C C# Db D D# Eb E F F# Gb G G# Ab A A# Bb B)
  UGLY_NOTE_NAMES = %w(E# B# Fb Cb)

  # The numerical pitches corresponding to LETTERS, starting
  # with (middle) C at 60.
  NATURAL_PITCHES = [ 0, 2, 4, 5, 7, 9, 11 ].map { |p| p + 60 }

  NOTE_REGEXP = /^([A-G])(|bb?|\#|x)(\d*)$/

  attr_reader   :letter
  attr_accessor :accidental, :pitch

  def Note.valid?(name)
    name =~ NOTE_REGEXP
  end

  def initialize(l, a, p)
    raise "letter must be a String" unless l.is_a?(String)
    raise "accidental must be an integer between -2 and +2" unless a >= -2 and a <= 2
    raise "pitch must be an integer" unless p.is_a?(Fixnum)
    Note.letter_pitch_delta(l, p)
    self.letter = l
    self.accidental = a
    self.pitch = p
  end

  def letter=(l)
    raise NoteExceptions::InvalidLetter.new(l) unless LETTERS.include? l
    @letter = l
  end

  # A Hash mapping letters of the natural notes to their pitches in octave 4
  # (from C4 to B4).
  NATURALS = Hash[LETTERS.zip(NATURAL_PITCHES)]

  # A Hash mapping letters of the natural notes to their letter indices,
  # i.e. C maps to 0, D maps to 1, ..., B maps to 6.
  LETTER_INDICES = Hash[LETTERS.zip(0..6)]

  def Note.letter_pitch_delta(letter, pitch)
    natural_pitch = NATURALS[letter]
    raise NoteExceptions::InvalidLetter.new(letter) unless natural_pitch
    delta = pitch - natural_pitch
    delta += 12 while delta < -6
    delta -= 12 while delta >  6
    if (delta.abs) > 2
      raise NoteExceptions::LetterPitchMismatch.new(letter, pitch, natural_pitch, delta)
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
    pitch = NATURALS[letter]
    raise NoteExceptions::InvalidLetter.new(letter) unless pitch
    new(letter, 0, pitch)
  end

  # Maps a note to its position relative to the centre of the alto
  # clef.  This relative scale is used to help calculate positions of
  # a note on a staff with a given clef.  Any accidental the note may
  # have does not affect its position on the staff.  The alto clef is
  # chosen for "calibrating" this relative scale because its middle
  # line corresponds to middle C; this means that this method will
  # return 0 for middle C or C# or Cb, 1 for middle D or Db or Dbb, -1
  # for middle B or Bb or even B#, and so on.
  def letter_index
    LETTER_INDICES[letter] + 7 * (naturalize.octave - 4)
  end

  # Shifts a note letter up the C major scale by the given number of
  # steps, and returns the resulting letter (*not* a Note instance).
  # For example, shifting C by 3 steps results in F, and shifting A by
  # 4 steps results in E.
  def Note.letter_shift(letter, steps)
    index = LETTER_INDICES[letter]
    raise NoteExceptions::InvalidLetter.new(letter) unless index
    return LETTERS[(index + steps) % LETTERS.length]
  end

  # Instantiate a note by a string representing its name, e.g. "C#" or
  # "Db3".  Defaults to octave 4.
  def Note.by_name(n)
    raise "Invalid note '#{n}'" unless n =~ NOTE_REGEXP
    letter, accidental_label, octave = $1, $2, $3
    accidental_delta = Accidental::DELTAS[accidental_label]
    octave = octave.empty? ? 4 : octave.to_i

    natural = by_letter(letter)
    pitch = (natural.pitch + accidental_delta) % 12
    pitch += 12 * (octave + 1)
    new(letter, accidental_delta, pitch)
  end

  class << self
    alias_method :[], :by_name
  end

  STANDARD_KEYS = STANDARD_KEY_NAMES.map { |n| Note.by_name(n) }
  UGLY_NOTES    = UGLY_NOTE_NAMES   .map { |n| Note.by_name(n) }
  DOUBLE_SHARPS = LETTERS.map { |l| Note.by_name(l + "x" ) }
  DOUBLE_FLATS  = LETTERS.map { |l| Note.by_name(l + "bb") }

  # Returns all notes representing the given pitch
  def Note.by_pitch(pitch)
    notes = [ ]
    for letter in LETTERS
      begin
        notes << Note.by_letter_and_pitch(letter, pitch)
      rescue NoteExceptions::LetterPitchMismatch
      end
    end
    notes.sort
  end

  SIMPLIFY_SINGLE_ACCIDENTALS = {
    'E#' => 'F',
    'B#' => 'C',
    'Fb' => 'E',
    'Cb' => 'B',
  }

  # Convert a double-sharp or double-flat into its simpler enharmonic
  # equivalent, and also simplify E#, B#, Fb, Cb.
  def simplify
    case accidental.abs
    when 0
      return self
    when 1
      simplified = SIMPLIFY_SINGLE_ACCIDENTALS[name]
      return simplified ? Note.by_name(simplified) : self
    when 2
      direction = accidental / accidental.abs
      new_letter = Note.letter_shift(letter, direction)
      new_accidental = accidental - direction*2
      return Note.new(new_letter, new_accidental, pitch)
    end
  end

  def simple?
    self == self.simplify
  end

  # Return a String representation of the note's name, without any
  # octave designators, e.g. "A", "F#", "Bb", "Bx", or "Ebb".
  def name
    letter + Accidental::LABELS[accidental]
  end

  # Return a String representation of the note's name, suffixed by the
  # octave number, e.g. "C4", "G#1", or "Eb6".
  def name_with_octave
    # http://en.wikipedia.org/wiki/Note#Note_designation_in_accordance_with_octave_name
    "%s%d" % [ name, octave ]
  end

  alias_method :to_s, :name_with_octave

  # Return a LilyPond representation of the note's name to be used
  # in a \relative context.
  def to_ly
    letter.downcase + Accidental::LY[accidental]
  end

  # Return the note's current octave.  Octaves start at C, with octave
  # 4 starting at middle C.
  def octave
    pitch / 12 - 1
  end

  # Set the note's octave.  Octaves start at C, with octave 4 starting
  # at middle C.
  def octave=(o)
    return if octave == o
    self.pitch = (o + 1) * 12 + pitch % 12
  end

  # As #octave=, but also returns the updated note to allow method
  # chaining.
  def octave!(o)
    self.octave = o
    return self
  end

  # Set the note's octave to 4.  Returns the updated note to allow
  # method chaining.
  def octave_squash!
    self.octave = 4
    return self
  end

  # Returns an instance of the note with the octave set to 4.  If it
  # was not 4 originally, a new Note object is instantiated to ensure
  # the receiver object is unchanged.
  def octave_squash
    return self if octave == 4
    dup.octave_squash!
  end

  # Remove any accidental from the note.  Returns the updated note to
  # allow method chaining.
  def naturalize!
    self.pitch -= self.accidental
    self.accidental = 0
    return self
  end

  # Returns an instance of the note with no accidentals.  If it
  # was not 4 originally, a new Note object is instantiated to ensure
  # the receiver object is unchanged.
  def naturalize
    return self if accidental == 0
    dup.naturalize!
  end

  # Return the position of the note on the given clef.  0 means the
  # note is on the centre line, 4 means the note is on the top line,
  # -4 means the bottom line, and so on.  Any value with an absolute
  # magnitude of 6 or higher requires ledger lines.
  def clef_position(clef)
    return letter_index - clef.centre_note.letter_index
  end

  # Return a LilyPond representation of the Note's name to be used in
  # an absolute pitch context.  LilyPond octave adjustment characters
  # are based on the letter name, not the actual pitch, e.g. whilst C4
  # (middle C) is represented by "c'", Cb3 which is a semitone below it
  # is represented by "cf'" not "cf" as you might expect.
  def to_ly_abs
    ly = letter.downcase + Accidental::LY[accidental]
    letter_octave = naturalize.octave
    ly + (letter_octave < 3 ? "," * (3 - letter_octave) : "'" * (letter_octave - 3))
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

