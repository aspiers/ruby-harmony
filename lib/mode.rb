require 'scale_type'
require 'note_collections'

class Mode
  attr_reader :degree, :scale_type, :index

  # Add a new mode to the catalogue.  The index is required so that
  # ordering of modes can be determined by the caller, which is
  # responsible for building the catalogue.
  def initialize(d, s, i)
    raise "degree must be a positive integer" unless d.is_a?(Fixnum) and d > 0
    raise "scale_type must be a ScaleType" unless s.is_a?(ScaleType)
    @degree = d
    @scale_type = s
    @index = i
    @name_override = nil
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
    degrees.inject(NoteArray.new()) do |acc, degree|
      note = scale_type.note(key_note, degree)
      note.octave = 0
      unless acc.empty?
        note.octave +=1 while note < acc[-1] # ensure ascending
      end
      acc << note
      acc
    end
  end

  # For a given starting note, find the key and mode which will result
  # in the best "spelling" of this scale.  This only makes sense for
  # symmetrical scale types which have fewer than 7 modes.  For
  # example, a mode which starts on C and is the 2nd degree of the
  # diminished scale could be thought of as:
  #
  #   - the 2nd degree of Bb diminished
  #   - the 2nd degree of A# diminished
  #   - the 4th degree of G  diminished
  #   - the 6th degree of E  diminished
  #   - the 8th degree of Db diminished
  #   - the 8th degree of C# diminished
  #
  # Each of these will result in a different enharmonic spelling of
  # the notes, and some are more suitable than others.  Selection of
  # the best key and mode is delegated to the corresponding ScaleType
  # instance.
  def best_display_key_and_mode(starting_note)
    key_note, best_degree = scale_type.key_and_degree(starting_note, degree)
    mode = best_degree == degree ? self : Mode.new(best_degree, scale_type, index)
    return key_note, mode
  end

  # Returns a NoteArray of the ascending notes of the mode, starting
  # on the given note.  For example, if the mode is dorian and the
  # given starting note is C, then it will return Bb major starting on
  # C.
  def notes_from(starting_note)
    # We have to allow the ScaleType to choose which (key, degree)
    # combination is going to allow the best way of representing the
    # notes; some ScaleTypes need to be fussy about this
    # (e.g. diminished).
    key_note, display_mode = best_display_key_and_mode(starting_note)
    display_mode.notes(key_note)
  end

  # Returns a ModeInKey instance representing this mode in the given key.
  def in_key(key_note)
    ModeInKey.new(self, key_note)
  end

  def name
    @name_override || scale_type.mode_name(degree)
  end
  alias_method :to_s, :name

  def name!(name)
    @name_override = name
  end

  def <=>(other)
    index <=> other.index
  end

end
