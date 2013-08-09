require 'accidental'

class Note < Struct.new(:letter, :accidental, :pitch)
  LETTERS = %w(C D E F G A B)
  NATURAL_PITCHES = [ 0, 2, 4, 5, 7, 9, 11 ]
  NATURALS = LETTERS.zip(NATURAL_PITCHES).map { |l, p| new(l, 0, p) }

  def Note.by_letter_and_pitch(letter, pitch)
    natural = NATURALS.find { |n| n.letter == letter }
    raise "no such note with letter '#{letter}'" unless natural
    delta = pitch - natural.pitch
    delta += 12 while delta < -6
    delta -= 12 while delta >  6

    if (delta.abs) > 2
      raise "pitch mismatch for letter '#{letter}' and pitch #{pitch} (natural #{natural.pitch}, delta #{delta})"
    end
    new(letter, delta, pitch)
  end

  def Note.by_letter(letter)
    NATURALS.find { |n| n.letter == letter }
  end

  def Note.letter_shift(letter, degree)
    index = LETTERS.find_index { |l| l == letter }
    raise "no such letter '#{letter}'" unless index
    return LETTERS[(index + degree) % LETTERS.length]
  end

  def Note.by_name(n)
    letter = n[0]
    accidental_label = n[1..-1]
    accidental_delta = ACCIDENTAL_DELTAS[accidental_label]
    raise "unrecognised accidental '#{accidental_label}'" unless accidental_delta

    natural = by_letter(letter)
    pitch = (natural.pitch + accidental_delta) % 12
    new(letter, accidental_delta, pitch)
  end

  def name
    letter + ACCIDENTAL_LABELS[accidental]
  end

  def to_s
    name
  end

  def to_ly
    letter.downcase + ACCIDENTAL_LY_LABELS[accidental]
  end

  def inspect
    "%-2s" % to_s
  end

  def <=>(other)
    pitch <=> other.pitch
  end
end

