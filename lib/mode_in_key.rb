require 'active_support/core_ext/integer/inflections'
require 'active_support/core_ext/string/indent'

class ModeInKey
  attr_accessor :mode, :key_note
  attr_writer   :original

  def ModeInKey.by_start_note(mode, starting_note)
    key_note, new_degree = mode.scale_type.key_and_degree(starting_note, mode.degree)

    if new_degree == mode.degree
      @original = nil
      return ModeInKey.new(mode, key_note)
    end

    # ScaleType instance has recommended shifting to a different
    # degree for better spelling of the notes.  So we construct a
    # new ModeInKey for obtaining the notes, but save the old one
    # inside it so we can still generate the same name.
    new_mode = Mode.new(new_degree, mode.scale_type, mode.index)
    original_key = new_mode.scale_type.note(key_note, new_degree - mode.degree + 1).octave_squash

    # if starting_note.name == 'C' && mode.degree == 2 && mode.scale_type.name == 'augmented'
    #   puts "#{starting_note} as deg #{mode.degree} of #{original_key} #{mode.scale_type} " + \
    #        "=> #{new_degree} deg of #{key_note}"
    # end

    mode_in_key          = ModeInKey.new(new_mode, key_note)
    original = mode_in_key.original = ModeInKey.new(mode, original_key)

    return mode_in_key
  end

  def initialize(mode, key_note)
    unless mode.is_a?(Mode)
      raise "mode must be a Mode not #{mode.class}"
    end
    # is_a? isn't reliable due to Rails reloading :-/
    #unless key_note.is_a?(Note)
    unless key_note.class.ancestors.map(&:to_s).include?('Note')
      raise "key_note must be a Note not #{key_note.class}"
    end
    self.mode = mode
    self.key_note = key_note

    @original = nil
  end

  def original
    @original || self
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

  # Builds an Array of modes of the given scale type starting on the
  # given note.
  def ModeInKey.all_for_scale_type(scale_type, starting_note)
    (1..scale_type.num_modes).map do |degree|
      orig_mode = Mode.new(degree, scale_type)
      ModeInKey.by_start_note(orig_mode, starting_note)
    end.sort
  end

  # Builds an Array of Arrays representing all modes of all registered
  # scales, starting on the given note:
  #
  #   [
  #     [ ... modes of 1st scale type ... ],
  #     [ ... modes of 2nd scale type ... ],
  #     ...
  #   ]
  def ModeInKey.all(starting_note)
    count = 0
    ScaleType.all.map do |scale_type|
      modes_in_key = ModeInKey.all_for_scale_type(scale_type, starting_note)
      #modes_in_key.each { |mode| mode.index = (count += 1) }
      modes_in_key
    end
  end

  def ModeInKey.output_modes(starting_note)
    s = ""

    for modes_in_key in ModeInKey.all(starting_note)
      for mode_in_key in modes_in_key
        mode = mode_in_key.mode
        orig = mode_in_key.original
        special_name = orig.mode.name
        name = special_name ? "%s %s" % [ starting_note, special_name ]
                            : orig.generic_description
        s << "%d %-30s %s\n" % [ orig.mode.degree, name, mode_in_key.notes ]
      end
      s << "\n"
    end

    return s
  end
end
