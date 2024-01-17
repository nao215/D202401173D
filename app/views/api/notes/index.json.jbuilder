json.status 200
json.notes @notes do |note|
  json.extract! note, :id, :title, :content, :user_id, :created_at, :updated_at
end
