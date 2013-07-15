class NoteSet < Set
  def note_names
    map { |note| note.name }
  end

  def to_s
    note_names.map { |n| "%-2s" % n }.join " "
  end
end
