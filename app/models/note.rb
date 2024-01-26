
class Note < ApplicationRecord
  belongs_to :user

  # validations
  validates_with NoteContentValidator
  # end for validations

  def save_with_error_handling
    if save
      true
    else
      log_error
      false
    end
  rescue => e
    log_error(e)
    false
  end

  private

  def log_error(exception = nil)
    error_message = exception ? exception.message : errors.full_messages.join(', ')
    Rails.logger.error "Failed to save note: #{error_message}"
    # Here you can add more error logging if needed
  end

  class << self
  end
end
