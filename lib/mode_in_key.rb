require 'active_support/core_ext/integer/inflections'
require 'active_support/core_ext/string/indent'

class ModeInKey
  attr_accessor :mode, :key_note

  def initialize(mode, key_note)
    self.mode = mode
    self.key_note = key_note
  end

  def generic_description
    text = '%s %s' % [ key_note, mode.scale_type.name ]
    if key_note != starting_note
      text = "%s degree of %s" % [ mode.degree.ordinalize, text ]
    end
    return text
  end

  def name
    generic = generic_description
    special = mode.name
    return special ? "%s %s\n(%s)" % [key_note, special, generic ] : generic
  end

  def to_s
    mode.name || generic_description
  end

  def to_ly
    text = to_s
    return ("\"%s\"\n" % text).indent(12) unless text.include? "\n"
    lines = text.split("\n").map { |line| "  \\line { \"#{line}\" }\n" }
    lines.unshift "\\column {\n"
    lines.unshift "\\override #'(baseline-skip . 2)\n"
    lines.push    "}\n"
    lines = lines.map { |line| line.indent(12) }
    return lines.join('')
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

  def ModeInKey.all(starting_note) # builds all modes starting on a given note
    count = 0
    ScaleType.all.map do |scale_type|
      (1..scale_type.num_modes).map do |degree|
        mode = Mode.new(degree, scale_type, count += 1)
        key_note = scale_type.key(starting_note, degree)
        ModeInKey.new(mode, key_note)
      end.sort
    end
  end

  def ModeInKey.output_modes(starting_note)
    s = ""

    for modes_in_key in ModeInKey.all(starting_note)
      for mode_in_key in modes_in_key
        mode = mode_in_key.mode
        name = mode.name || mode_in_key.generic_description
        s << "%d %-30s %s\n" % [ mode.degree, name, mode_in_key.notes ]
      end
      s << "\n"
    end

    return s
  end
end
