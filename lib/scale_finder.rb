require 'erb'
require 'ostruct'
require 'set'
require 'pp'

require 'note'
require 'scale_type'
require 'mode'

class ScaleFinder
  TEMPLATE_DIR = File.dirname(__FILE__) + '/../ly'

  @@verbosity = 0

  def set_verbosity(verbosity)
    @@verbosity = verbosity
  end

  def debug(level, msg)
    puts msg if level <= @@verbosity
  end

  def scales_matching_chord(scales, chord)
    debug 4, ".. " + chord.sort.to_s
    scales.find_all { |scale|
      debug 4, "-- " + scale.notes.sort.to_s
      (chord.pitches & scale.pitches).length == chord.length
    }
  end

  # Brute-force iteration through all possible chords (within an octave
  # span) up to a certain size, finding which match any of the scales we
  # know, and of those, which uniquely identify that scale.
  # 
  # Note that if fixed_chord_notes is big enough, it's feasible that a
  # chord uniquely identifying a scale which contains all the notes in
  # fixed_chord_notes, may not actually contain all the notes of
  # fixed_chord_notes itself.  So we need to iterate over all
  # combinations of variable_chord_notes and then add in
  # fixed_chord_notes to perform the scale matching, rather than
  # iterating over all combinations of fixed_chord_notes +
  # variable_chord_notes.
  # 
  # Returns nested Hash:
  #   { uniquely_identified_scale => { chord_size => [ chord, ... ] }
  def find_identifiers(scales, fixed_chord_notes, variable_chord_notes)
    identifiers = Hash[ scales.map { |scale| [scale, {}] } ]

    # fixed_chord_notes might be enough to uniquely identify a mode
    for num_variable_notes in 0..(variable_chord_notes.size)
      # More than 7 (or even 5) variable notes not possible in a 7 note
      # diatonic scale.  Change this if we want to narrow/expand the
      # search to pentatonic/hexatonic/octatonic scales etc.
      break if fixed_chord_notes.size + num_variable_notes > 7

      chords_seen = Hash.new(false)

      debug 1, "Checking all #{num_variable_notes}-note chords ..."
      for pitches in (0..11).to_a.combination(num_variable_notes)
        identifier_candidate_chord = PitchSet.to_note_set(pitches)
        chord_to_match = fixed_chord_notes + identifier_candidate_chord
        chord_size = identifier_candidate_chord.size

        chord_text = fixed_chord_notes.to_s.strip
        alterations = identifier_candidate_chord - fixed_chord_notes
        chord_text += " + #{alterations.to_s.strip}" unless alterations.empty?
        debug 4, "    seen #{chord_to_match}" if chords_seen[chord_text]
        next if chords_seen[chord_text]
        chords_seen[chord_text] = true

        matches = scales_matching_chord(scales, chord_to_match)

        case matches.length
        when 0
          debug 2, "    #{chord_text} didn't match any modes"
        when 1
          identified_mode = matches[0]
          debug 1, "*   #{chord_text} uniquely identified: #{identified_mode}"
          identifiers[identified_mode][chord_size] ||= [ ]
          identifiers[identified_mode][chord_size].push identifier_candidate_chord
        else
          matches_to_show = matches.dup
          if @@verbosity == 2
            matches_to_show = matches.first(2)
            matches_to_show += [ '...' ] if matches.length > 2
          end
          debug 2, ".   #{chord_text} matched #{matches.length} modes: " + \
          matches_to_show.join(', ')
        end
      end
      debug 1, ''
    end

    return identifiers
  end

  def output_summary_header(descr, fixed_chord_notes, variable_chord_notes)
    debug 1, "-" * 72
    debug 1, ''
    chord = fixed_chord_notes.to_s.strip.gsub(/\s+/, ' ')
    header = "%s: %s" % [ descr, chord ] # + #{variable_chord_notes.to_s.strip}"
    puts header
    puts "=" * header.size, "\n"
  end

  class TemplateData < OpenStruct
    def render(template)
      ERB.new(template, nil, '-').result(binding)
    end
  end

  def identify_modes(fixed_chord_notes, variable_chord_notes, starting_note_name)
    starting_note = Note.by_name(starting_note_name)
    scales = ModeInKey.all(starting_note).flatten
    identifiers = find_identifiers(scales, fixed_chord_notes, variable_chord_notes)

    # map chord size to an Array of all scales which need that number of
    # notes to uniquely identify the scale.
    scales_by_chord_size = { }

    # map [ chord_size, chords_count ] => [ scale, ... ]
    distinctiveness = { }

    ly_scales = [ ]

    identifiers.sort_by do |mode_in_key, chords_by_size|
      mode_in_key.mode.index
    end.each do |scale, chords_by_size|
      if chords_by_size.empty?
        scales_by_chord_size[0] ||= [ ]
        scales_by_chord_size[0].push scale
        debug 3, "no chords found uniquely identifying #{scale}!"
        next
      end

      chord_size, chords = chords_by_size.sort.first # show smallest identifying chords
      scales_by_chord_size[chord_size] ||= [ ]
      scales_by_chord_size[chord_size].push scale
      chords_count = chords.size # number of identifying chords of this size
      distinctiveness[[chord_size, chords_count]] ||= [ ]
      distinctiveness[[chord_size, chords_count]].push scale
      puts "#{chord_size} note chords uniquely identifying #{scale}:"
      for chord in chords
        remaining = scale.notes.reject { |note| chord.include? note }
        alterations = remaining.reject { |note| fixed_chord_notes.include? note }
        chord_in_scale = chord.sort.map { |note|
          note_in_scale = scale.notes.find { |n| n.pitch == note.pitch }
          unless note_in_scale
            raise "Couldn't find note in scale #{scale} for pitch #{pitch}"
          end
          note_in_scale
        }
        puts "    %-14s + %s" % [ NoteArray[*chord_in_scale], NoteArray[*alterations] ]
        ly_scales.push [ scale.to_s, ly_notes(scale, chord_in_scale) ]
      end
    end

    return distinctiveness, scales_by_chord_size, ly_scales
  end

  def ly_notes(scale, chord_in_scale)
    scale.notes.map do |note|
      (chord_in_scale.include?(note) ? '\emphasise ' : '') + note.to_ly
    end
  end

  def output_uniqueness(distinctiveness)
    puts <<EOF

  Modes sorted by "uniqueness" (ease of identification)
  -----------------------------------------------------

EOF

    for sizes, modes in distinctiveness.sort_by { |s, m| [s[0], -s[1]] }
      chord_size, num_chords = sizes
      puts "modes uniquely identified by #{num_chords} #{chord_size}-note chord#{num_chords == 1 ? '' : 's'}: " + modes.join(', ')
    end
  end

  def output_notes_needed(modes_by_chord_size)
    puts <<EOF

  How many notes are needed?
  --------------------------

EOF

    for size, modes in modes_by_chord_size.sort
      if size == 0
        puts "modes with no unique identifier found: " + modes.join(', ')
      else
        puts "#{modes.length} mode#{modes.length == 1 ? '' : 's'} uniquely identified by #{size} notes: " + modes.join(', ')
      end
    end
  end

  def run(fixed_chord_notes, root, descr)
    fixed_chord_notes = NoteSet[*fixed_chord_notes.map { |name| Note.by_name(name) }]
    alterations = PitchSet.chromatic_scale - fixed_chord_notes
    descr = root + descr unless descr.include? '/'

    output_summary_header(descr, fixed_chord_notes, alterations)
    distinctiveness, scales_by_chord_size, ly_scales =
      identify_modes(fixed_chord_notes, alterations, root)

    data = TemplateData.new(
      descr:  descr,
      chord:  fixed_chord_notes.map(&:to_ly).join(" "),
      scales: ly_scales,
    )
    File.write('ly/out.ly', data.render(File.read(TEMPLATE_DIR + '/template.ly.erb')))

    # output_uniqueness(distinctiveness)
    # output_notes_needed(scales_by_chord_size)
  end
end
