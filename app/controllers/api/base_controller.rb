# typed: ignore
module Api
  include NotesService
  class BaseController < ActionController::API
    include ActionController::Cookies
    include Pundit::Authorization

    # =======End include module======

    rescue_from ActiveRecord::RecordNotFound, with: :base_render_record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :base_render_unprocessable_entity
    rescue_from Exceptions::AuthenticationError, with: :base_render_authentication_error
    rescue_from ActiveRecord::RecordNotUnique, with: :base_render_record_not_unique
    rescue_from Pundit::NotAuthorizedError, with: :base_render_unauthorized_error

    def error_response(resource, error)
      {
        success: false,
        full_messages: resource&.errors&.full_messages,
        errors: resource&.errors,
        error_message: error.message,
        backtrace: error.backtrace
      }
    end

    private

    def base_render_record_not_found(_exception)
      render json: { message: I18n.t('common.404') }, status: :not_found
    end

    def base_render_unprocessable_entity(exception)
      render json: { message: exception.record.errors.full_messages }, status: :unprocessable_entity
    end

    def base_render_authentication_error(_exception)
      render json: { message: I18n.t('common.404') }, status: :not_found
    end

    def base_render_unauthorized_error(_exception)
      render json: { message: I18n.t('common.errors.unauthorized_error') }, status: :unauthorized
    end

    def base_render_record_not_unique
      render json: { message: I18n.t('common.errors.record_not_uniq_error') }, status: :forbidden
    end

    def custom_token_initialize_values(resource, client)
      token = CustomAccessToken.create(
        application_id: client.id,
        resource_owner: resource,
        scopes: resource.class.name.pluralize.downcase,
        expires_in: Doorkeeper.configuration.access_token_expires_in.seconds
      )
      @access_token = token.token
      @token_type = 'Bearer'
      @expires_in = token.expires_in
      @refresh_token = token.refresh_token
      @resource_owner = resource.class.name
      @resource_id = resource.id
      @created_at = resource.created_at
      @refresh_token_expires_in = token.refresh_expires_in
      @scope = token.scopes
    end

    def update_note
      note_id = params[:id]
      content = params[:content]

      # Validate note ID format
      unless note_id.to_s.match?(/\A\d+\z/)
        return render json: { message: "Wrong format." }, status: :unprocessable_entity
      end

      # Find the note and check if it exists
      note = Note.find_by(id: note_id)
      unless note
        return render json: { message: "Note not found." }, status: :not_found
      end

      # Check if the user is authorized to update the note
      authorize note, policy_class: NotePolicy

      # Validate content
      if content.blank?
        return render json: { message: "Note content cannot be empty." }, status: :unprocessable_entity
      end

      # Update the note
      result = NotesService::Update.new(note_id: note_id, user_id: current_resource_owner.id, content: content).execute

      if result[:error]
        render json: { message: result[:error] }, status: :unprocessable_entity
      else
        render json: {
          status: 200,
          note: note.as_json.merge(updated_at: note.updated_at.iso8601)
        }, status: :ok
      end
    end

    def current_resource_owner
      return super if defined?(super)
    end
  end
end
