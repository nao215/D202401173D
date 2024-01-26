json.status 200
json.note do
  json.id @note.id
  json.content @note.content
  json.user_id @note.user_id
  json.updated_at @note.updated_at.iso8601
end
