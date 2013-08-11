require 'scale_type'
require 'note_set'

class Mode
  attr_reader :degree, :scale_type, :index

  def initialize(d, s, i)
    @degree = d
    @scale_type = s
    @index = i
  end

  # rotate intervallic increments by different degrees of the scale
  # to generate the modes for this scale type
  def increments
    @increments ||= scale_type.increments.rotate(degree - 1)[0...-1]
  end

  def degrees
    @degrees ||= (1..(increments.size+1)).to_a.rotate(degree - 1)
  end

  # Returns a NoteArray of the ascending notes of the mode, in the given key.
  def notes(key_note)
    NoteArray.new(degrees.map { |degree| scale_type.note(key_note, degree) })
  end

  # Returns a NoteArray of the ascending notes of the mode, starting
  # on the given note.  For example, if the mode is dorian and the
  # given starting note is C, then it will return Bb major starting on
  # C.
  def notes_from(starting_note)
    key_note = scale_type.key(starting_note, degree)
    notes(key_note)
  end

  # Returns a ModeInKey instance representing this mode in the given key.
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
