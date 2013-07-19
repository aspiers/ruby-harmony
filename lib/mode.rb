require 'scale'

class Mode < Struct.new(:degree, :scale_type, :index)
  DEGREES = %w(ion dor phryg lyd mixo aeol loc)

  # rotate intervallic increments by different degrees of the scale
  # to generate the 7 modes for this scale type
  def increments
    scale_type.increments.rotate(degree - 1)[0...-1]
  end

  def degrees
    (1..7).to_a.rotate(degree - 1)
  end

  def notes(key_note)
    degrees.map { |degree| scale_type.note(key_note, degree) }
  end

  def notes_from(starting_note)
    key_note = scale_type.key(starting_note, degree)
    notes(key_note)
  end

  def to_s
    deg = DEGREES[degree - 1]
    return deg if scale_type.name == 'maj'
    "%s %s" % [ deg, scale_type.name ]
  end

  def <=>(other)
    index <=> other.index
  end

  def Mode.all # builds all 28 modes
    @@modes ||= \
    begin
      ScaleType.all.map do |scale_type|
        modes = [ ]
        degree = 3 # start with lydian
        begin
          mode = Mode.new(degree + 1, scale_type, modes.length - 1)
          modes.push mode
          degree = (degree + 4) % 7 # move through modes from open to closed
        end while degree % 7 != 3 # stop when we get back to lydian
        modes
      end
    end
  end
end
