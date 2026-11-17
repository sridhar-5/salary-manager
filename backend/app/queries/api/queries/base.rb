module API
  module Queries
    class Base
      DEFAULT_PAGE = 1
      DEFAULT_LIMIT = 10

      attr_reader :records

      def initialize(params)
        @params = params
        @filters = params.fetch(:filters, {})
        @scope = default_scope
      end

      def call
        filter_records
        sort_records
        paginate_records
        @records = scope
        self
      end

      def count
        records.total_count
      end

      private

      attr_reader :params, :filters, :scope

      def default_scope
        raise NotImplementedError
      end

      def filter_records; end

      def sort_records; end

      def paginate_records
        @scope = scope.page(page).per(limit)
      end

      def page
        params[:page] || DEFAULT_PAGE
      end

      def limit
        params[:limit] || DEFAULT_LIMIT
      end
    end
  end
end
