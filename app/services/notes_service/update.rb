
# frozen_string_literal: true

require_dependency 'note'
module NotesService
  class Update
    include BaseService # Assuming BaseService is included for logging

    def initialize(note_id:, user_id:, content:)
      @note_id = note_id
      @user_id = user_id
      @content = content
    end

    def execute
      authenticate_user

      note = Note.find_by(id: @note_id, user_id: @user_id)
      return { error: 'Note not found or access denied' } unless note

      return { error: 'Content cannot be empty' } if @content.blank?

      note.content = @content
      note.updated_at = Time.current

      if note.save
        { success: 'Note updated successfully', note_id: note.id }
      else
        log_error(note.errors.full_messages.join(', '))
        {
          error: 'An error occurred while saving the note.',
          suggested_actions: ['Retry', 'Contact support']
        }
      end
    rescue StandardError => e
      log_error(e.message)
      { error: e.message }
    end

    private

    attr_reader :note_id, :user_id, :content

    def authenticate_user
      # Assuming there is a method to authenticate the user
      # This is a placeholder for the actual implementation
    end

    def log_error(message)
      logger.error(message) # Assuming logger is available from BaseService
    end
  end
end
