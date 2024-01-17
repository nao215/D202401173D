class Api::NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:unsaved_changes]
  before_action :authorize_note, only: [:unsaved_changes]

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

end
