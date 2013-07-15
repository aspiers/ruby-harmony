require 'note_set'
require 'scale'

class Mode < Struct.new(:degree, :scale_type, :index)
  DEGREES = %w(ion dor phryg lyd mixo aeol loc)

  # rotate intervallic increments by different degrees of the scale
  # to generate the 7 modes for this scale type
  def increments
    scale_type.increments.rotate(degree)[0...-1]
  end

  def notes
  end

  def to_s
    deg = DEGREES[degree]
    return deg if scale_type.name == 'maj'
    "%s %s" % [ deg, scale_type.name ]
  end

  def <=>(other)
    index <=> other.index
  end

  def Mode.all # builds all 28 modes
    @@modes ||= \
    begin
      modes = [ ]
      ScaleType.all.each do |scale_type|
        degree = 3 # start with lydian
        begin
          mode = Mode.new(degree, scale_type, modes.length - 1)
          modes.push mode
          debug 2, "%-15s %s" % [ mode, mode.notes.to_s ]
          degree = (degree + 4) % 7 # move through modes from open to closed
        end while degree % 7 != 3 # stop when we get back to lydian
        debug 2, ''
      end
      debug 2, ''
      modes
    end
  end
end
