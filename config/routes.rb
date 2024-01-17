require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Existing routes
  get '/api/notes/:id/unsaved' => 'notes#unsaved_changes'
  put '/api/notes/:id', to: 'api/base_controller#update_note'

  # New route added
  post '/api/notes/:id/save_error', to: 'notes#save_error'

  # Other routes...
end
