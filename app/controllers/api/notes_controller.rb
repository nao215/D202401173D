class Api::NotesController < Api::BaseController
  before_action :doorkeeper_authorize!, except: [:unsaved_changes]
  before_action :authenticate_user!, only: [:unsaved_changes]
  before_action :set_note, only: [:unsaved_changes, :save_error]
  before_action :authorize_note, only: [:unsaved_changes, :save_error]

  # GET /api/notes/:id/unsaved
  def unsaved_changes
    if @note.updated_at > @note.created_at
      render json: { status: 200, unsaved_changes: true }
    else
      render json: { status: 200, unsaved_changes: false }
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def save_error
    begin
      return render json: { error: "Wrong format." }, status: :bad_request unless @note

      error_message = params[:error] || "An error occurred while saving the note."
      BaseService.new.log_error(error_message)

      render json: { status: 200, message: "Your changes could not be saved at this time. Please try again later." }, status: :ok
    rescue StandardError => e
      render json: { error: "An unexpected error occurred on the server." }, status: :internal_server_error
    end
  end

  private

  def set_note
    note_id = params[:id]
    @note = Note.find_by(id: note_id)
  end

  def authorize_note
    policy = NotePolicy.new(current_user, @note)
    render json: { error: 'Forbidden' }, status: :forbidden unless policy.update?
  end

  def current_user
    # Assuming there's a method to retrieve the current authenticated user
    # This method should be implemented in the Api::BaseController or a concern
    super || doorkeeper_token&.resource_owner_id&.then { |id| User.find(id) }
  end
end
