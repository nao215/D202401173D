require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Merge the new and existing routes
  namespace :api do
    resources :notes, only: [:index, :show] do
      member do
        put :update
      end
    end
  end

  # ... other routes ...
end
