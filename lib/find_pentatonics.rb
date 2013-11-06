require 'chord_type'
require 'diatonic_scale_type'
require 'symmetrical_scale_type'
require 'scale_finder'
require 'pentatonic_matcher'

require 'pp'

def matching_scales(key, fixed_chord_notes)
  scale_types = [
    DiatonicScaleType.all_in_subclass,
    #PentatonicScaleType.all_in_subclass,
    SymmetricalScaleType.all_in_subclass,
  ].flatten
  catalogue = ModeInKey.from_scale_types(key, scale_types).flatten
  @scalefinder = ScaleFinder.new(fixed_chord_notes, 'blah', 'treble', catalogue)
  @scalefinder.set_verbosity(0)
  @scalefinder.identify_modes
  @scalefinder.scales_matched
end

key = Note['C']
chord_type_name = ARGV[0] || '7'
chord_type = ChordType[chord_type_name]
raise "'#{chord_type_name}' not recognised" unless chord_type
chord_notes = chord_type.notes(key)

catalogue = [ PentatonicScaleType::MAJOR ]
catalogue = PentatonicScaleType.all_in_subclass

matches = {}
for mode_in_key, note_set, chord in matching_scales(key, chord_notes)
  # puts mode_in_key.name(" ")
  # puts "  " + note_set.note_names.join(" ")
  matches_for_scale = PentatonicMatcher.from_note_set(note_set, catalogue)
  # matches_for_scale.sort.reverse.each do |num, pentatonics|
  #   puts "%3d %s" % [num, pentatonics.join(", ")] if num == 5
  # end
  perfect_matches = matches_for_scale[5]
  next unless perfect_matches
  # puts "  %s" % perfect_matches.inspect

  for perfect_match in perfect_matches
    text = "%s - %s" % [perfect_match.name, perfect_match.note_names.join(" ")]
    matches[text] ||= {}
    matches[text][mode_in_key.name(" ")] = 1
  end
end

for pentatonic, modes_in_keys in matches.sort
  puts "#{pentatonic} is contained within the following scales:"
  for mode_in_key in modes_in_keys.keys
    puts "  " + mode_in_key
  end
  puts
end
