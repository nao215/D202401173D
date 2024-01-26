# frozen_string_literal: true

module NotesService
  module Pagination
    DEFAULT_PER_PAGE = 10

    def self.paginate(collection, current_page, per_page = DEFAULT_PER_PAGE)
      paginated_collection = collection.page(current_page).per(per_page)
      total_items = paginated_collection.total_count
      total_pages = paginated_collection.total_pages

      {
        notes: paginated_collection,
        total_items: total_items,
        total_pages: total_pages
      }
    end
  end
end
