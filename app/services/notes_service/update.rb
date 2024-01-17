
# frozen_string_literal: true

module NotesService
  class Update
    def initialize(note_id:, user_id:, title:, content:)
      @note_id = note_id
      @user_id = user_id
      @title = title
      @content = content
    end

    def execute
      note = Note.find_by(id: @note_id, user_id: @user_id)
      return { error: 'Note not found or access denied' } unless note

      return { error: 'Title cannot be empty' } if @title.blank?
      return { error: 'Content cannot be empty' } if @content.blank?

      note.title = @title
      note.content = @content
      note.updated_at = Time.current

      if note.save
        { success: 'Note updated successfully', note_id: note.id, title: note.title, updated_at: note.updated_at }
      else
        { error: note.errors.full_messages.join(', ') }
      end
    rescue StandardError => e
      { error: e.message }
    end

    private

    attr_reader :note_id, :user_id, :title, :content
  end
end
