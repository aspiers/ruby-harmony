require 'set'

module PitchCollection
  def to_s
    note_names.map { |n| "%-3s" % n }.join " "
  end
end

# A Set of numbers corresponding to absolute pitches.
class PitchSet < Set
  include PitchCollection

  # An Array arbitrarily mapping integers 0..11 to note name Strings
  # (e.g. the second element is arbitrarily chosen as 'Db' rather than
  # 'C#').
  NOTES = [ 'C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B' ]

  def PitchSet.to_note_set(pitches)
    notes = pitches.map { |pitch| Note.by_name(PitchSet::NOTES[pitch]) }
    NoteSet[*notes]
  end

  # Returns a NoteSet with the 12 notes of the chromatic scale.
  def PitchSet.chromatic_scale
    to_note_set(0..11)
  end

  # Returns an array of note name Strings representing the PitchSet.
  def note_names
    map { |note| NOTES[note] }
  end
end

# A mixin for any collection of Note instances
module NoteCollection
  include PitchCollection

  # Enumerates the names (as Strings) of notes in the collection
  def note_names
    map { |note| note.name }
  end

  # Enumerates the numerical pitches of notes in the collection
  def pitches
    map { |note| note.pitch }
  end

  # Produce a new collection from the old, with all notes transposed
  # into a single octave where the numerical pitches range from 0 to 11.
  def octave_squash
    new_notes = map do |note|
      note.octave_squash
    end
    self.class.new(new_notes)
  end

  # Shifts the collection up by the given number of octaves.  Can be
  # negative to shift down.  Returns the collection to allow method
  # chaining.
  def octave_shift!(delta)
    each do |note|
      note.octave += delta
    end
    self
  end

  def furthest_from_centre(clef)
    max_by { |note| note.clef_position(clef).abs }
  end

  def centre_on_clef(clef)
    debug = false
    done = false
    while ! done
      furthest = furthest_from_centre(clef)
      furthest_pos = furthest.clef_position(clef)
      furthest_dist = furthest_pos.abs
      puts "furthest is #{furthest} @ #{furthest_pos}" if debug
      if furthest_pos > 0
        # We're top heavy, i.e. highest note is further from centre
        # than lowest.  Will shifting down an octave make things any
        # better?  Let's look at the impact on the top and bottom
        # notes.
        new_top_pos    = furthest_pos - 7
        new_bottom_pos = min.clef_position(clef) - 7
        puts "  top heavy; new (top, bottom) would be (#{new_top_pos}, #{new_bottom_pos})" if debug
        if new_top_pos.abs < furthest_dist and new_bottom_pos.abs < furthest_dist
          puts "    -- shift down" if debug
          octave_shift!(-1)
        else
          # Must be equally balanced, nothing more to do.
          done = true
        end
      elsif furthest_pos < 0
        # We're bottom heavy, i.e. lowest note is further from centre
        # than highest.  Will shifting up an octave make things any
        # better?  Let's look at the impact on the top and bottom
        # notes.
        new_bottom_pos = furthest_pos + 7
        new_top_pos    = max.clef_position(clef) + 7
        puts "  bottom heavy; new (top, bottom) would be (#{new_top_pos}, #{new_bottom_pos})" if debug
        if new_top_pos.abs < furthest_dist and new_bottom_pos.abs < furthest_dist
          puts "    ++ shift up" if debug
          octave_shift!(+1)
        else
          # Must be equally balanced, nothing more to do.
          done = true
        end
      else
        done = true
      end
    end
  end

  def contains_equivalent_note?(note)
    detect { |n| n === note }
  end

  def num_sharps
    inject(0) { |total, note| note.accidental > 0 ? total += note.accidental : total }
  end

  def num_flats
    inject(0) { |total, note| note.accidental < 0 ? total -= note.accidental : total }
  end

  def num_accidentals
    num_sharps + num_flats
  end

  def num_letters
    inject(Set.new) { |set, note| set << note.letter }.size
  end

  # Convert the collection to a chord in LilyPond syntax.  We have to
  # take extra care to add advisory accidentals to any note which
  # shares its letter with any other note in the same chord, thanks to
  # this bug: https://code.google.com/p/lilypond/issues/detail?id=2236
  def to_ly_abs
    dupe_letters = group_by { |note| note.letter }.select { |k, v| v.size > 1 }.map(&:first)
    ly_notes = [ ]
    each do |note|
      ly = note.to_ly_abs
      if dupe_letters.include?(note.letter)
        ly += "!" if note.accidental == 0
      end
      ly_notes << ly
    end
    ly_notes.join(' ')
  end
end

class NoteSet < Set
  include NoteCollection
end

class NoteArray < Array
  include NoteCollection
end
