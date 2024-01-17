class Api::NotesController < Api::BaseController
  before_action :doorkeeper_authorize!

  def show
    begin
      note_id = params[:id]
      raise ArgumentError, 'Note ID is required and must be a valid integer.' unless note_id.present? && note_id.to_i.to_s == note_id

      note_service = NotesService::Show.new(note_id, current_resource_owner.id)
      note_details = note_service.execute

      render json: { status: 200, note: note_details }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'The requested note does not exist.' }, status: :not_found
    rescue Pundit::NotAuthorizedError
      render json: { error: 'User does not have permission to access the resource.' }, status: :forbidden
    rescue ArgumentError => e
      render json: { error: e.message }, status: :bad_request
    rescue StandardError => e
      render json: { error: 'An unexpected error occurred on the server.' }, status: :internal_server_error
    end
  end

  private

  def current_resource_owner
    # Assuming there's a method to find the current user based on the OAuth token
    # This method should be implemented as part of the OAuth authentication logic
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
