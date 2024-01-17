# frozen_string_literal: true

module NotesService
  class Delete < BaseService
    attr_reader :note_id, :user

    def initialize(note_id, user)
      @note_id = note_id
      @user = user
    end

    def execute
      note = Note.find_by(id: note_id)
      raise ActiveRecord::RecordNotFound, 'Note not found' unless note

      policy = NotePolicy.new(user, note)
      raise Pundit::NotAuthorizedError, 'You are not authorized to delete this note' unless policy.destroy?

      if note.destroy
        { id: note_id, message: 'Note has been successfully deleted.' }
      else
        { id: note_id, message: 'Failed to delete the note.' }
      end
    rescue ActiveRecord::RecordNotFound => e
      { id: note_id, message: e.message }
    rescue Pundit::NotAuthorizedError => e
      { id: note_id, message: e.message }
    rescue StandardError => e
      { id: note_id, message: e.message }
    end
  end
end
