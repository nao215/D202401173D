# frozen_string_literal: true

module NotesService
  class Index < BaseService
    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    def execute
      authenticate_user
      notes = query_notes
      formatted_notes = format_notes(notes)
      paginated_notes = paginate_notes(formatted_notes)

      {
        notes: paginated_notes,
        total_items: notes.size,
        total_pages: paginated_notes.total_pages
      }
    end

    private

    def authenticate_user
      # Assuming there's a method to authenticate the user
      User.find(user_id)
    end

    def query_notes
      Note.where(user_id: user_id)
    end

    def format_notes(notes)
      notes.select(:id, :content, :created_at, :updated_at)
    end

    def paginate_notes(notes)
      notes.page(params[:page] || 1).per(params[:per_page] || 20)
    end
  end
end
