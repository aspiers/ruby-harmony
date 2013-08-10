require 'active_support/core_ext/integer/inflections'

require 'scale_type'
require 'accidental'

class Interval < Struct.new(:degree, :accidental)
  def from(from_note)
    natural = DiatonicScaleType::MAJOR.note(from_note, degree)
    to_note = natural.dup
    unless accidental == 0
      to_note.pitch      += accidental
      to_note.accidental += accidental
    end
    return to_note
  end

  def name
    Accidental::LABELS[accidental] + degree.to_s
  end

  def adjective
    return "aug" if accidental == 1

    a =
      case ((degree - 1) % 7) + 1
      when 1
        [nil, ""]
      when 2, 3, 6, 7
        %w(minor major)
      when 4, 5
        %w(dim perfect)
      end

    return a[accidental + 1] || 'unrecognised'
  end

  def long_name
    case name
    when "1"
      "unison"
    when "b9"
      return "flat 9th"
    when "#11"
      return "sharp 11th"
    when "b13"
      return "flat 13th"
    else
      return adjective + ' ' + (degree == 1 ? "unison" : degree.ordinalize)
    end
  end

  def Interval.by_name(name)
    if name !~ /^(bb|b||#|x)(\d\d?)$/
      raise "Invalid interval '#{name}'"
    end
    accidental = Accidental::DELTAS[$1]
    degree = $2.to_i
    return new(degree, accidental)
  end

  def <=>(other)
    c = Note.by_name('C')
    [degree, from(c).pitch] <=> [other.degree, other.from(c).pitch]
  end
end
