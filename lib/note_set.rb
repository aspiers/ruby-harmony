require 'set'

module PitchCollection
  def to_s
    note_names.map { |n| "%-3s" % n }.join " "
  end
end

class PitchSet < Set
  include PitchCollection

  NOTES = [ 'C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B' ]

  def PitchSet.to_note_set(pitches)
    notes = pitches.map { |pitch| Note.by_name(PitchSet::NOTES[pitch]) }
    NoteSet[*notes]
  end

  def PitchSet.chromatic_scale
    to_note_set(0..11)
  end

  def note_names
    map { |note| NOTES[note] }
  end
end

module NoteCollection
  include PitchCollection

  def note_names
    map { |note| note.name }
  end

  def pitches
    map { |note| note.pitch }
  end
end

class NoteSet < Set
  include NoteCollection
end

class NoteArray < Array
  include NoteCollection
end
