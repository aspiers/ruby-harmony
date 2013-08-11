require 'scale_type'
require 'note_set'

class Mode
  attr_accessor :degree, :scale_type, :index

  def initialize(d, s, i)
    self.degree = d
    self.scale_type = s
    self.index = i
  end

  # rotate intervallic increments by different degrees of the scale
  # to generate the modes for this scale type
  def increments
    scale_type.increments.rotate(degree - 1)[0...-1]
  end

  def degrees
    (1..(increments.size+1)).to_a.rotate(degree - 1)
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

  def name
    scale_type.mode_name(degree)
  end
  alias_method :to_s, :name

  def <=>(other)
    index <=> other.index
  end

end
