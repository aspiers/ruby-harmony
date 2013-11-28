require 'note'
require 'note_collections'
require 'exceptions'

class ScaleType
  @@all = [ ] # all scale types instantiated in any subclass
  def ScaleType.all; @@all end

  class << self
    def initialize_class
      # all scale types instantiated by a particular subclass
      @all_in_subclass  = [ ]
    end
    attr_reader :all_in_subclass

    def inherited(subclass)
      subclass.initialize_class
    end
  end

  attr_reader :name, :increments, :num_modes, :transpositions, :index

  # The number of modes is equal to the number of notes in the
  # smallest repeating cycle of increments.
  def symmetrical_modes?
    num_modes < increments.size
  end

  # The number of transpositions (keys) is equal to the number of
  # semitones in the cycle.
  def symmetrical_keys?
    transpositions < 12
  end

  # Thanks to Messiaen for helping me realise those facts:
  # http://en.wikipedia.org/wiki/Modes_of_limited_transposition

  @@by_name = {}

  def initialize(name, increments, num_modes, transpositions)
    if @@by_name[name]
      $stderr.puts "already initialized #{name} with index #{@@by_name[name].index}; all: #{ScaleType.all}"
    end
    @@by_name[name] = self

    @name = name
    @increments = increments
    @num_modes = num_modes
    @transpositions = transpositions

    @@all.push(self)
    self.class.all_in_subclass.push(self)

    @index = @@all.length - 1
  end

  def offset_from_key(degree)
    # concatenate as many increments together as we need
    # to reach the degree, which may be greater than the
    # number of notes in the scale (e.g. 11, 13)
    incs = increments * (1 + (degree - 1) / num_modes)
    increments_from_key = incs.first(degree - 1)
    return increments_from_key.inject(0) { |a,x| a + x }
  end

  # Override to provide special names for selected modes.
  def mode_name(degree)
    nil
  end

  # Return the number of letters to shift the key note by in order to
  # reach the letter which the given degree should have.  Some
  # non-diatonic scales will need to override this to provide a
  # non-linear progression of letters as the scale ascends.
  def letter_shift(degree)
    degree - 1
  end

  # Return the note which is the given degree of the scale.
  def note(key_note, degree)
    letter = Note.letter_shift(key_note.letter, letter_shift(degree))
    pitch = key_note.pitch + offset_from_key(degree)
    begin
      Note.by_letter_and_pitch(letter, pitch)
    rescue NoteExceptions::LetterPitchMismatch => e
      raise $!, "#{$!} whilst calculating degree #{degree} of #{name} in #{key_note}" #, $!.backtrace
    end
  end

  # Find the degree of the given note in the given key.
  def degree_of(search_note, key_note)
    degree = (1..(@increments.size + 1)).find { |d|
      note(key_note, d).octave_squash === search_note.octave_squash
    }
    unless degree
      raise "Couldn't find #{note} in #{key_note} #{self}"
    end
    return degree
  end

  # Given a note which is a degree of a scale, find the original key.
  # e.g. 'C' and 3 should return Ab.
  def key(note, degree)
    key_letter = Note.letter_shift(note.letter, - letter_shift(degree))
    key_pitch = note.pitch - offset_from_key(degree)
    return Note.by_letter_and_pitch(key_letter, key_pitch)
  end

  # Same as #key, but the degree is also returned unchanged, to be
  # consistent with other ScaleTypes (e.g. diminished) which have to
  # be able to suggest a different mode.
  def key_and_degree(note, degree)
    return key(note, degree).octave_squash, degree
  end

  alias_method :inspect, :name
  alias_method :to_s,    :name
end
