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

  def update
    note_id = params[:id]
    title = params[:title]
    content = params[:content]

    # Validate parameters
    unless note_id.present? && note_id.to_i.to_s == note_id.to_s
      return render json: { error: "Note ID is required and must be a valid integer." }, status: :bad_request
    end

    if title.blank?
      return render json: { error: "The title is required." }, status: :unprocessable_entity
    end

    if content.blank?
      return render json: { error: "The content is required." }, status: :unprocessable_entity
    end

    # Find the note and authorize
    note = Note.find_by(id: note_id)
    return render json: { error: "The requested note does not exist." }, status: :not_found unless note

    authorize note, policy_class: NotePolicy

    # Update the note
    service = NotesService::Update.new(note_id: note_id, user_id: current_resource_owner.id, title: title, content: content)
    result = service.execute

    if result[:error].present?
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      note.reload
      render json: { status: 200, note: note.as_json }, status: :ok
    end
  rescue Pundit::NotAuthorizedError
    render json: { error: "User does not have permission to update the note." }, status: :forbidden
  end

  private

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
