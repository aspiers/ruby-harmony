class ChordType
  @@all = [ ]

  def ChordType.get_intervals(chord_type)
    intervals = []

    case chord_type
    when /^min\/maj7/
      intervals += %w(b3 7)
    when /^maj7/
      intervals += %w(3 7)
    when /^min7/
      intervals += %w(b3 b7)
    when /^maj9/
      intervals += %w(3 7 9)
    when /^min9/
      intervals += %w(b3 b7 9)
    when /^min11/
      intervals += %w(b3 b7 9 11)
    when /^7/
      intervals += %w(3 b7)
    when /^min6/
      intervals += %w(b3 6)
    when /^6/
      intervals += %w(3 6)
    when /^13/
      intervals += %w(b3 b7 9)
    end

    case chord_type
    when /(b5|b13|#5|#11)/
      %w(b5 b13 #5 #11).each do |alteration|
        intervals << alteration if chord_type.include? alteration
      end
    else
      intervals << '5'
    end

    case chord_type
    when /(b9|#9)/
      %w(b9 #9).each do |alteration|
        intervals << alteration if chord_type.include? alteration
      end
    when /9/
      intervals << '9'
      intervals << '3'  unless intervals.detect { |i| i.include? '3' }
      intervals << 'b7' unless intervals.detect { |i| i.include? '6' or i.include? '7' }
    end

    case chord_type
    when /sus4/
      intervals << '4'
    when /sus7/
      intervals += %w(4 b7)
    when /sus9/
      intervals += %w(4 b7 9)
    end

    intervals << '2' if chord_type =~ /add2/ and ! intervals.include? '2'

    intervals.map { |name| Interval.by_name(name) }.sort
  end
end
