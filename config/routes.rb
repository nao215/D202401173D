require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
  
  # Existing route for getting unsaved changes of a note
  get '/api/notes/:id/unsaved' => 'notes#unsaved_changes'
  
  # New route for creating a note
  post '/api/notes', to: 'notes#create'
  
  # Existing route for updating a note
  put '/api/notes/:id', to: 'api/base_controller#update_note'
  
  # ... other routes ...
end
