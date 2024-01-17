json.status 201
json.note do
  json.id @note.id
  json.title @note.title
  json.content @note.content
  json.user_id @note.user_id
  json.created_at @note.created_at.iso8601(3)
end
