require 'scale_type'

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
end

