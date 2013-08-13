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
      n = note.dup
      n.pitch %= 12
      n
    end
    self.class.new(new_notes)
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
