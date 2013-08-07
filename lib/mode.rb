require 'scale_type'
require 'note_set'

class Mode < Struct.new(:degree, :scale_type, :index)
  #DEGREES = %w(ion dor phryg lyd mixo aeol loc)
  DEGREES = %w(ionian dorian phrygian lydian mixo aeolian locrian)
  #DEGREES = %w(ionian dorian phrygian lydian mixolydian aeolian locrian)

  # rotate intervallic increments by different degrees of the scale
  # to generate the 7 modes for this scale type
  def increments
    scale_type.increments.rotate(degree - 1)[0...-1]
  end

  def degrees
    (1..7).to_a.rotate(degree - 1)
  end

  def notes(key_note)
    NoteArray.new(degrees.map { |degree| scale_type.note(key_note, degree) })
  end

  def pitches_from(starting_note)
    NoteArray.new(notes_from(starting_note).map { |note| note.pitch })
  end

  def notes_from(starting_note)
    key_note = scale_type.key(starting_note, degree)
    notes(key_note)
  end

  def in_key(key_note)
    ModeInKey.new(self, key_note)
  end

  def to_s
    deg = DEGREES[degree - 1]
    return deg if scale_type.name == 'maj'
    "%s %s" % [ deg, scale_type.name ]
  end

  def <=>(other)
    index <=> other.index
  end

end

class ScaleInKey < Struct.new(:mode, :key_note)
  def to_s
    text = "%s %s" % [ starting_note, mode ]
    text += " (in #{key_note})" if key_note != starting_note
    text
  end

  def inspect
    to_s
  end

  def notes
    mode.notes(key_note)
  end

  def starting_note
    notes.first
  end

  def pitches
    notes.map { |note| note.pitch }
  end

  def num_sharps
    notes.inject(0) { |total, note| note.accidental > 0 ? total += note.accidental : total }
  end

  def num_flats
    notes.inject(0) { |total, note| note.accidental < 0 ? total -= note.accidental : total }
  end

  def accidentals
    [ num_sharps, num_flats ]
  end

  def <=>(other)
    [ num_flats - num_sharps ] <=> [ other.num_flats - other.num_sharps ]
  end
end

class ModeInKey < ScaleInKey
  def ModeInKey.all(starting_note) # builds all 28 modes starting on a given note
    count = 0
    ScaleType.all.map do |scale_type|
      (1..7).map do |degree|
        mode = Mode.new(degree, scale_type, count += 1)
        key_note = scale_type.key(starting_note, degree)
        ModeInKey.new(mode, key_note)
      end.sort
    end
  end
end
