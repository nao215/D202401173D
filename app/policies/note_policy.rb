# typed: true
# frozen_string_literal: true

require 'logger'

class NotePolicy < ApplicationPolicy
  def update?
    user.id == record.user_id
  end

  def destroy?
    user.id == record.user_id
  end

  def save_note_with_error_handling(id, content, user_id)
    note = Note.find_by(id: id, user_id: user_id)
    return 'Note not found' unless note

    note.content = content
    if note.save
      'Note saved successfully'
    else
      logger = Logger.new(STDOUT)
      logger.error("Failed to save note: #{note.errors.full_messages.join(', ')}")
      'Error saving note. Please retry or contact support.'
    end
  end
end

# Note: The ApplicationPolicy class is assumed to be already defined as per the project structure.
# The user and record are assumed to be set by the controller when initializing the policy.
