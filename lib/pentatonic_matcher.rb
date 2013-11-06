require 'mode'
require 'mode_in_key'
require 'pentatonic_scale_type'
require 'note_collections'

class PentatonicMatcher
  def self.from_note_set(note_set, pentatonic_catalogue)
    note_set = note_set.octave_squash
    pitch_set = note_set.pitches
    matches = {}
    note_set.each do |note|
      for scale_type in pentatonic_catalogue
        pentatonic_mode = Mode.new(1, scale_type)
        pentatonic_mode_in_key = ModeInKey.by_start_note(pentatonic_mode, note)
        pentatonic_notes = NoteSet[*pentatonic_mode_in_key.notes].octave_squash
        pentatonic_pitches = pentatonic_notes.pitches
        common_pitches = pitch_set & pentatonic_pitches
        matches[common_pitches.length] ||= []
        matches[common_pitches.length].push(pentatonic_mode_in_key)
      end
    end
    matches
  end
end
