module Accidental
  LABELS = {
    -2 => 'bb',
    -1 => 'b',
     0 => '',
    +1 => '#',
    +2 => 'x',
  }
  DELTAS = LABELS.invert

  LY = {
    -2 => 'ff',
    -1 => 'f',
     0 => '',
    +1 => 's',
    +2 => 'ss',
  }

  LY_MARKUP = {
    -2 => '\raise #0.5 \fontsize #-3 \doubleflat',
    -1 => '\raise #0.5 \fontsize #-3 \flat',
     0 => '\raise #0.5 \fontsize #-3 \natural',
    +1 => '\raise #0.5 \fontsize #-3 \sharp',
    +2 => '\raise #0.5 \fontsize #-3 \doublesharp',
  }

  def Accidental.to_ly_markup(text)
    text = text.gsub(/\b([A-G])(b\b|bb\b|#|x\b)/) do |m|
      letter, accidental = $1, $2
      delta = DELTAS[accidental]
      letter + '"' + Accidental::LY_MARKUP[delta] + ' "'
    end
    text.gsub(/([^a-zA-Z]|\d)(b|bb|#|x|natural\s*)(1\d|[1-7])/) do |m|
      prefix, accidental, number = $1, $2, $3
      accidental = '' if accidental =~ /natural/
      delta = DELTAS[accidental]
      prefix + '"' + Accidental::LY_MARKUP[delta] + ' "' + number
    end
  end
end
