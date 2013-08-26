require 'note'

class Clef
  attr_reader :name, :centre_note

  @@all = [ ]
  @@all_by_name = { }

  def initialize(note_name, name, centre_note_name)
    @note_name = note_name
    @name = name

    centre_note = Note[centre_note_name]

    @centre_note = centre_note
    @@all << self
    @@all_by_name[name] = self
  end

  def Clef.all; @@all end

  def Clef.by_name(name)
    @@all_by_name[name]
  end

  class << self
    alias_method :[], :by_name
  end

  alias_method :to_s, :name

  def <=>(other)
    other.centre_note <=> centre_note
  end

  TREBLE = new('G', 'treble', 'B4')
  ALTO   = new('C', 'alto',   'C4')
  TENOR  = new('C', 'tenor',  'A3')
  BASS   = new('F', 'bass',   'D3')
end
