class NoteService::Create < BaseService
  attr_reader :user_id, :content

  def initialize(user_id, content)
    @user_id = user_id
    @content = content
  end

  def call
    user = User.find_by(id: user_id)
    return { error: 'User not found or not logged in' } unless user

    return { error: 'Content cannot be empty' } if content.blank?
    return { error: 'Content violates policies' } unless valid_content?(content)

    note = user.notes.new(content: content, created_at: Time.now, updated_at: Time.now)

    if note.save
      { success: 'Note created successfully', note_id: note.id }
    else
      { error: note.errors.full_messages.join(', ') }
    end
  rescue StandardError => e
    { error: e.message }
  end

  private

  def valid_content?(content)
    # Add content validation logic here (e.g., check for prohibited language, character limits)
    true
  end
end

# Note: This is a simplified example and assumes that the User model has a `notes` association.
# You may need to adjust the code according to your actual project requirements and coding standards.
