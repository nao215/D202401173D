class Api::NotesController < Api::BaseController
  before_action :authenticate_user!, except: [:show]
  before_action :set_note, only: [:unsaved_changes]
  before_action :authorize_note, only: [:unsaved_changes]
  before_action :doorkeeper_authorize!

  # GET /api/notes/:id
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

  # DELETE /api/notes/:id
  def destroy
    note_id = params[:id].to_i
    return render json: { error: "Note ID is required and must be a valid integer." }, status: :bad_request unless note_id.is_a?(Integer) && note_id > 0

    user = current_resource_owner
    result = NotesService::Delete.new(note_id, user).execute

    if result[:id]
      render json: { status: 200, message: "Note has been successfully deleted." }, status: :ok
    else
      render json: { message: result[:message] }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Note not found' }, status: :not_found
  rescue Pundit::NotAuthorizedError
    render json: { message: 'You are not authorized to delete this note' }, status: :forbidden
  end

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

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def authorize_note
    policy = NotePolicy.new(current_user, @note)
    render json: { error: 'Forbidden' }, status: :forbidden unless policy.update?
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
