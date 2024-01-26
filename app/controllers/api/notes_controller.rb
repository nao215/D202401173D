class Api::NotesController < ApplicationController
  before_action :authenticate_user!, except: [:create]
  before_action :doorkeeper_authorize!, only: [:create]
  before_action :set_note, only: [:unsaved_changes]
  before_action :authorize_note, only: [:unsaved_changes]

  # POST /api/notes
  def create
    note_service = NoteService::Create.new(note_params[:user_id], nil, note_params[:content])
    result = note_service.call

    if result[:error].present?
      handle_error_response(result[:error])
    else
      render json: { status: 201, note: format_note_response(result) }, status: :created
    end
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

  def note_params
    params.require(:note).permit(:content, :user_id)
  end

  def set_note
    @note = Note.find(params[:id])
  end

  def authorize_note
    policy = NotePolicy.new(current_user, @note)
    render json: { error: 'Forbidden' }, status: :forbidden unless policy.update?
  end

  def handle_error_response(error)
    case error
    when 'User not found or not logged in', 'User not found.'
      render json: { error: error }, status: :not_found
    when 'Content cannot be empty.'
      render json: { error: error }, status: :unprocessable_entity
    else
      render json: { error: error }, status: :internal_server_error
    end
  end

  def format_note_response(result)
    # Assuming there's a method to format the note response
    # This method should be implemented as per the application's requirements
    # For example:
    {
      id: result[:note].id,
      content: result[:note].content,
      user_id: result[:note].user_id,
      created_at: result[:note].created_at,
      updated_at: result[:note].updated_at
    }
  end
end
