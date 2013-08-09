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
    ACCIDENTAL_LABELS[accidental] + degree.to_s
  end

  def Interval.by_name(name)
    if name !~ /^(bb|b||#|x)(\d\d?)$/
      raise "Invalid interval '#{name}'"
    end
    accidental = ACCIDENTAL_DELTAS[$1]
    degree = $2.to_i
    return new(degree, accidental)
  end

  def <=>(other)
    c = Note.by_name('C')
    [degree, from(c).pitch] <=> [other.degree, other.from(c).pitch]
  end
end
