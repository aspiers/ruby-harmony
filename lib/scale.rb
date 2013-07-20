require 'note'
require 'note_set'

class ScaleType
  @@all = [ ]

  attr_reader :name, :increments, :symmetry

  def initialize(name, increments, symmetry)
    @name = name
    @increments = increments
    @@all.push self
    @index = @@all.length - 1
  end

  def ScaleType.all; @@all end
  def inspect;       name  end
end

class DiatonicScale < ScaleType
  def key(note, degree)
    # Given a note which is a degree of a scale, find the original key.
    # e.g. 'C' and 3 should return Ab
    key_letter = Note.letter_shift(note.letter, 1 - degree)
    key_pitch = note.pitch - offset_from_key(degree)
    key_pitch += 12 if key_pitch < 0
    return Note.by_letter_and_pitch(key_letter, key_pitch)
  end

  def offset_from_key(degree)
    increments_from_key = increments.first(degree - 1)
    return increments_from_key.inject(0) { |a,x| a + x }
  end

  # Return the note which is the given degree of the scale.
  def note(key_note, degree)
    letter = Note.letter_shift(key_note.letter, degree - 1)
    pitch = key_note.pitch + offset_from_key(degree)
    pitch -= 12 if pitch >= 12
    return Note.by_letter_and_pitch(letter, pitch)
  end

  def notes(key)
    @notes ||=
      begin
        NoteArray[*increments.inject([0]) do |array, note|
          array.push(array.last + note)
        end]
      end
  end

  MAJOR          = DiatonicScale.new('maj',      [ 2, 2, 1, 2, 2, 2, 1    ], 7)
  MELODIC_MINOR  = DiatonicScale.new('mel min',  [ 2, 1, 2, 2, 2, 2, 1    ], 7)
  HARMONIC_MAJOR = DiatonicScale.new('harm maj', [ 2, 2, 1, 2, 1, 3, 1    ], 7)
  HARMONIC_MINOR = DiatonicScale.new('harm min', [ 2, 1, 2, 2, 1, 3, 1    ], 7)
  # DOUBLE_HARMONIC = new('dbl harm', [ 1, 3, 1, 2, 1, 3, 1    ], 7)
  # WHOLE_TONE    = new('whole',    [ 2, 2, 2, 2, 2, 2       ], 1)
  # DIMINISHED    = new('dim',      [ 2, 1, 2, 1, 2, 1, 2, 1 ], 2)
  # AUGMENTED     = new('aug',      [ 3, 1, 3, 1, 3, 1       ], 2)
end
