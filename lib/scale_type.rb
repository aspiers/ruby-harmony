require 'note'
require 'note_collections'

class ScaleType
  @@all = [ ] # all scale types instantiated in any subclass
  def ScaleType.all; @@all end

  class << self
    def initialize_class
      # all scale types instantiated by a particular subclass
      @all_in_subclass  = [ ]
    end
    attr_reader :all_in_subclass

    def inherited(subclass)
      subclass.initialize_class
    end
  end

  attr_reader :name, :increments, :num_modes, :transpositions

  # The number of modes is equal to the number of notes in the
  # smallest repeating cycle of increments.
  def symmetrical_modes?
    num_modes < increments.size
  end

  # The number of transpositions (keys) is equal to the number of
  # semitones in the cycle.
  def symmetrical_keys?
    transpositions < 12
  end

  # Thanks to Messiaen for helping me realise those facts:
  # http://en.wikipedia.org/wiki/Modes_of_limited_transposition

  def initialize(name, increments, num_modes, transpositions)
    @name = name
    @increments = increments
    @num_modes = num_modes
    @transpositions = transpositions

    @@all.push(self)
    self.class.all_in_subclass.push(self)

    @index = @@all.length - 1
  end

  # Return the note which is the given degree of the scale.
  def note(key_note, degree)
    letter = Note.letter_shift(key_note.letter, degree - 1)
    pitch = key_note.pitch + offset_from_key(degree)
    return Note.by_letter_and_pitch(letter, pitch)
  end

  # Given a note which is a degree of a scale, find the original key.
  # e.g. 'C' and 3 should return Ab.  The degree is also returned
  # unchanged, to be consistent with other ScaleTypes
  # (e.g. diminished) which have to be able to suggest a different
  # mode.
  def key_and_degree(note, degree)
    key_letter = Note.letter_shift(note.letter, 1 - degree)
    key_pitch = note.pitch - offset_from_key(degree)
    key_pitch += 12 if key_pitch < 0
    return Note.by_letter_and_pitch(key_letter, key_pitch), degree
  end

  alias_method :inspect, :name
  alias_method :to_s,    :name
end

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

class SymmetricalScaleType < ScaleType
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
  DIMINISHED      = new('diminished',      [ 2, 1, 2, 1, 2, 1, 2, 1       ], 2,  3)
  # AUGMENTED       = new('aug',             [ 3, 1, 3, 1, 3, 1             ], 2,  4)
  # MESSIAEN_THREE    = new("Messian's 3rd", [ 2, 1, 1, 2, 1, 1, 2, 1, 1    ], 3, 4)
  # MESSIAEN_FOURTH   = new("Messian's 4th", [ 1, 1, 3, 1, 1, 1, 3, 1       ], 3, 4)
  # MESSIAEN_FIFTH    = new("Messian's 5th", [ 1, 4, 1, 1, 4, 1             ], 3, 6)
  # MESSIAEN_SIXTH    = new("Messian's 6th", [ 2, 2, 2, 1, 2, 2, 2, 1       ], 4, 6)
  # MESSIAEN_SEVENTH  = new("Messian's 7th", [ 1, 1, 1, 2, 1, 1, 1, 1, 2, 1 ], 5, 6)

  class << DIMINISHED

    # Memoized version of best_key_and_degree
    def key_and_degree(note, degree)
      n = note.name
      @best_key_degree_cache ||= { }
      @best_key_degree_cache[n] = { } unless @best_key_degree_cache.has_key?(n)
      @best_key_degree_cache[n][degree] ||= best_key_and_degree(note, degree)
    end

    # Return the best [key, degree] pair.
    #
    # The notes in the desired scale are fixed by the given note and
    # the fact that it is the given degree within the scale.  However,
    # since this is a symmetrical scale, multiple keys can generate
    # the desired scale.  So we search all the possibilities to find
    # the most suitable key, ranked by these factors in descending
    # order of importance:
    #
    #   1. Preference is given to keys which result in the
    #      scale containing the given note, over those which
    #      contain an enharmonically equivalent pitch.  So
    #      if the caller asks for a scale with an F# in, they
    #      are more likely to get one with F# in rather than Gb.
    #   2. The more letters in the scale, the better.  For example
    #      a scale with Eb, E, Gb, and G will be at a disadvantage
    #      to one with Eb, E, F#, G, all other things being equal.
    #   3. Preference is given to the key which places the given
    #      note at the given degree.
    #   4. Preference is given to keys generating scales with
    #      fewer total accidentals.
    #   5. Preference is given to keys resulting in the fewest
    #      notes with the same letter as the given note.
    #
    # Once the most suitable key has been selected, a (potentially
    # new) degree has to be returned alongside it, so that generation
    # of notes in the mode can start in the correct place.
    #
    # For example, for the diminished scale, if the given note is C at
    # degree 2, then there are six possible keys: E, G, Bb, A#, C#,
    # and Db.  Here is the internal ranking results:
    #
    #   [[0, -7, 1, 4, 4], [G , [A , Bb, C , Db, Eb, E , F#, G ]]]
    #   [[0, -7, 1, 4, 6], [E , [F#, G , A , Bb, C , C#, D#, E ]]]
    #   [[0, -6, 0, 4, 2], [Bb, [Bb, C , Db, Eb, E , Gb, G , A ]]]
    #   [[0, -6, 1, 4, 2], [A#, [A#, C , C#, D#, E , F#, G , A ]]]
    #   [[0, -6, 1, 4, 8], [C#, [D#, E , F#, G , A , A#, C , C#]]]
    #   [[0, -6, 1, 4, 8], [Db, [Eb, E , Gb, G , A , Bb, C , Db]]]
    #
    # E and G are the best candidates because:
    #
    #   1. they both contain C (rather than B#; actually
    #      in this case all candidates tie on this top factor),
    #   2. and use all 7 letters.
    #   3. Neither place C at degree 2, and
    #   4. they both contain 4 accidentals.
    #
    # However, G is best, because:
    #
    #   5. it results in only one note with the letter C, whereas E
    #      places it at the 6th degree which means that the mode would
    #      begin with C, C# ... (since we've hardcoded the diminished
    #      scale to repeat a letter at the 6th and 7th degrees) - and
    #      given that a typical use for this scale would be over a
    #      C7b9#11, we want a Db rather than a C#.
    def best_key_and_degree(note, degree)
      key_letter = Note.letter_shift(note.letter, 1 - degree)
      key_pitch = note.pitch - offset_from_key(degree)
      primary_key = Note.by_letter_and_pitch(key_letter, key_pitch)
      primary_key.octave = 0
      candidates = [ ]

      equivalent_keys(primary_key).each do |candidate_key|
        # Use a disposable Mode just to calculate the notes rendered
        # relative to each candidate replacement key.  Its degree has
        # no impact on the ranking.  Once we know the notes, we can
        # calculate the degree of this new scale which the original
        # note corresponds to.
        tmp_mode = Mode.new(1, self, -1)
        notes = tmp_mode.notes(candidate_key).octave_squash
        candidate_degree = 1 + notes.find_index { |n| n === note }
        if degree != candidate_degree
          notes = Mode.new(degree, self, -1).notes(candidate_key).octave_squash
        end

        candidates << [
          [
            # sorting criteria
            notes.include?(note) ? 0 : 1,
            -notes.num_letters,
            candidate_key == primary_key ? 0 : 1,
            notes.num_accidentals,
            notes.count { |n| n.letter == note.letter }
          ],
          [
            # actual data we need at the end
            candidate_key, candidate_degree, notes
          ],
        ]
      end

      if candidates.empty?
        raise "BUG: none of candidates #{equivalent_keys(note)} matched"
        return primary_key
      end

      candidates.sort!
      # require 'pp'
      # puts "searching #{self} candidates where degree #{degree} is #{note} ..."
      # pp candidates

      best = candidates[0]
      key, degree, notes = best[1]

      return key, degree
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

  class << WHOLE_TONE
    def mode_name(degree)
      return name
    end

    def note(key_note, degree)
      super(key_note, degree).simplify
    end
  end
end
