if @note.errors.any?
  json.error @note.errors.full_messages.first
else
  json.status 201
  json.note do
    json.id @note.id
    json.content @note.content
    json.user_id @note.user_id
    json.created_at @note.created_at.iso8601
  end
end

unless @user
  json.error "User not found."
end
