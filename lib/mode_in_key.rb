require 'active_support/core_ext/integer/inflections'
require 'active_support/core_ext/string/indent'

class ModeInKey
  attr_accessor :mode, :key_note

  def initialize(mode, key_note)
    raise "mode must be a Mode" unless mode.is_a?(Mode)
    raise "key_note must be a Note" unless key_note.is_a?(Note)
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

  def special_description
    special = mode.name
    return special ? "%s %s" % [ starting_note, special ] : nil
  end

  def name
    generic = generic_description
    special = special_description
    return generic if generic == special
    return special ? "%s\n(%s)" % [ special, generic ] : generic
  end

  def to_s
    special_description || generic_description
  end

  def to_ly
    text = name
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
    @notes ||= mode.notes(key_note)
  end

  def starting_note
    notes.first
  end

  def pitches
    notes.map { |note| note.pitch }
  end

  def num_sharps
    @sharps ||= notes.num_sharps
  end

  def num_flats
    @flats ||= notes.num_flats
  end

  def num_accidentals
    num_sharps + num_flats
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
        key_note, deg = scale_type.key_and_degree(starting_note, degree)
        mode = Mode.new(deg, scale_type, count += 1) if deg != degree
        ModeInKey.new(mode, key_note)
      end.sort
    end
  end

  def ModeInKey.output_modes(starting_note)
    s = ""

    for modes_in_key in ModeInKey.all(starting_note)
      for mode_in_key in modes_in_key
        mode = mode_in_key.mode
        name = mode.name ? "%s %s" % [ starting_note, mode.name ]
                         : mode_in_key.generic_description
        s << "%d %-30s %s\n" % [ mode.degree, name, mode_in_key.notes ]
      end
      s << "\n"
    end

    return s
  end
end
