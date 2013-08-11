require 'note'
require 'note_collections'

class ScaleType
  @@all = [ ]

  attr_reader :name, :increments, :num_modes, :transpositions

  # The number of modes is eqal to the number of notes in the smallest
  # repeating cycle of increments.  The number of transpositions
  # (keys) is equal to the number of semitones in the cycle.
  #
  # Thanks to Messiaen for helping me realise that.
  # http://en.wikipedia.org/wiki/Modes_of_limited_transposition

  def initialize(name, increments, num_modes, transpositions)
    @name = name
    @increments = increments
    @num_modes = num_modes
    @transpositions = transpositions

    @@all.push self
    @index = @@all.length - 1
  end

  def ScaleType.all; @@all end

  alias_method :inspect, :name
  alias_method :to_s,    :name
end

class DiatonicScaleType < ScaleType
  def initialize(name, increments)
    super(name, increments, 7, 12)
  end

  def key(note, degree, mode=nil)
    # Given a note which is a degree of a scale, find the original key.
    # e.g. 'C' and 3 should return Ab
    key_letter = Note.letter_shift(note.letter, 1 - degree)
    key_pitch = note.pitch - offset_from_key(degree)
    key_pitch += 12 if key_pitch < 0
    return Note.by_letter_and_pitch(key_letter, key_pitch)
  end

  def offset_from_key(degree)
    # concatenate as many increments together as we need
    # to reach the degree, which may be greater than the
    # number of notes in the scale (e.g. 11, 13)
    incs = increments * (1 + (degree - 1) / num_modes)
    increments_from_key = incs.first(degree - 1)
    return increments_from_key.inject(0) { |a,x| a + x }
  end

  # Return the note which is the given degree of the scale.
  def note(key_note, degree)
    letter = Note.letter_shift(key_note.letter, degree - 1)
    pitch = key_note.pitch + offset_from_key(degree)
    return Note.by_letter_and_pitch(letter, pitch)
  end

  def mode_name(degree)
    nil
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
      when 3
        "lydian augmented"
      when 4
        "lydian dominant"
      when 6
        "locrian natural 2"
      when 7
        "altered"
      else
        super
      end
    end
  end
end

class SymmetricalScaleType < ScaleType
  def key(note, degree, mode=nil)
    # Given a note which is a degree of a scale, find the original key.
    # e.g. 'C' and 3 should return Ab
    key_letter = Note.letter_shift(note.letter, 1 - degree)
    key_pitch = note.pitch - offset_from_key(degree)
    key_pitch += 12 if key_pitch < 0
    return Note.by_letter_and_pitch(key_letter, key_pitch)
  end

  def offset_from_key(degree)
    # concatenate as many increments together as we need
    # to reach the degree, which may be greater than the
    # number of notes in the scale (e.g. 11, 13)
    incs = increments * (1 + (degree - 1) / num_modes)
    increments_from_key = incs.first(degree - 1)
    return increments_from_key.inject(0) { |a,x| a + x }
  end

  def equivalent_key_pitches(key_note)
    equivalent_key_count = 12 / transpositions
    (0..(equivalent_key_count - 1)).map { |x| key_note.pitch + x * transpositions }
  end

  def equivalent_keys(key_note)
    equivalent_key_pitches(key_note).map do |pitch|
      Note.by_pitch(pitch).find_all { |x| x.simple? }
    end.flatten
  end

  WHOLE_TONE      = new('whole tone',      [ 2, 2, 2, 2, 2, 2             ], 1,  2)
  DIMINISHED      = new('dim',             [ 2, 1, 2, 1, 2, 1, 2, 1       ], 2,  3)
  # AUGMENTED       = new('aug',             [ 3, 1, 3, 1, 3, 1             ], 2,  4)
  # MESSIAEN_THREE    = new("Messian's 3rd", [ 2, 1, 1, 2, 1, 1, 2, 1, 1    ], 3, 4)
  # MESSIAEN_FOURTH   = new("Messian's 4th", [ 1, 1, 3, 1, 1, 1, 3, 1       ], 3, 4)
  # MESSIAEN_FIFTH    = new("Messian's 5th", [ 1, 4, 1, 1, 4, 1             ], 3, 6)
  # MESSIAEN_SIXTH    = new("Messian's 6th", [ 2, 2, 2, 1, 2, 2, 2, 1       ], 4, 6)
  # MESSIAEN_SEVENTH  = new("Messian's 7th", [ 1, 1, 1, 2, 1, 1, 1, 1, 2, 1 ], 5, 6)

  class << DIMINISHED
    def key(note, degree, mode)
      # Find the key which results in the most letters and fewest
      # accidentals, whilst still including the given note.
      #candidate_keys = equivalent_key_pitches(note)

      key_letter = Note.letter_shift(note.letter, 1 - degree)
      key_pitch = note.pitch - offset_from_key(degree)
      key_pitch += 12 if key_pitch < 0
      return Note.by_letter_and_pitch(key_letter, key_pitch)
    end

    def letter_shift(degree)
      steps_from_key = (degree - 1) % 7
      return steps_from_key - 1 if degree >= 7
      return steps_from_key
    end

    # Return the note which is the given degree of the scale.
    def note(key_note, degree)
      letter = Note.letter_shift(key_note.letter, letter_shift(degree))
      pitch = key_note.pitch + offset_from_key(degree)
      Note.by_letter_and_pitch(letter, pitch).simplify
    end

    def mode_name(degree)
      return degree == 2 ? 'auxiliary diminished' : nil
    end
  end
end
