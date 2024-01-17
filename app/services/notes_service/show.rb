# frozen_string_literal: true

module NotesService
  class Show < BaseService
    def initialize(note_id, user_id)
      @note_id = note_id
      @user_id = user_id
    end

    def execute
      note = Note.find(@note_id)
      user = User.find(@user_id)
      policy = NotePolicy.new(user, note)

      raise ActiveRecord::RecordNotFound unless policy.update?

      {
        id: note.id,
        title: note.title,
        content: note.content,
        created_at: note.created_at,
        updated_at: note.updated_at
      }
    end
  end
end
