require 'note'
require 'mode'

class SymmetricalScaleType < ScaleType
  def equivalent_key_pitches(key_note)
    equivalent_key_count = 12 / transpositions
    (0..(equivalent_key_count - 1)).map { |x| key_note.pitch + x * transpositions }
  end

  def equivalent_keys(key_note)
    equivalent_key_pitches(key_note).map do |pitch|
      Note.by_pitch(pitch).find_all { |x| x.simple? }
    end.flatten
  end

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
      primary_key = key(note, degree)
      primary_key.octave = 0
      candidates = [ ]

      debug = false
      #debug = name == "augmented" && degree == 2 && note.name == 'C'

      equivalent_keys(primary_key).each do |candidate_key|
        # In this new candidate key, the starting note is the same,
        # therefore the degree of the mode has changed, and we need to
        # know what it is in order to instantiate a Mode for
        # calculating the note spellings which we will then use to
        # rank the suitability of all candidates.
        begin
          candidate_degree = degree_of(note, candidate_key)
          notes = Mode.new(candidate_degree, self).notes(candidate_key).octave_squash
        rescue NoteExceptions::LetterPitchMismatch
          # We were probably trying to figure out the 6th degree of A#
          # whole tone or something like that, so scratch this key
          # from the candidate list.
          if debug
            puts "rejected candidate key #{candidate_key}"
          end
          next
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
      if debug
        require 'pp'
        puts "searching #{self} candidates where degree #{degree} is #{note} ..."
        pp candidates
      end

      best = candidates[0]
      key, degree, notes = best[1]

      return key, degree
    end

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
