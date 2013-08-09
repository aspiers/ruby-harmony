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
end

class NoteSet < Set
  include NoteCollection
end

class NoteArray < Array
  include NoteCollection
end
