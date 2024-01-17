# frozen_string_literal: true

module NotesService
  module Formatting
    def self.format_notes(notes)
      notes.map do |note|
        {
          id: note.id,
          content: note.content,
          created_at: note.created_at,
          updated_at: note.updated_at
        }
      end
    end
  end
end
