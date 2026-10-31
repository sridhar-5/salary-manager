module API
  module Queries
    class Base
      DEFAULT_LIMIT = 10
      DEFAULT_PAGE = 1
      DEFAULT_ORDER = "DESC"

      attr_reader :limit, :page, :search, :filters, :sort, :order, :params, :scope

      delegate :count, to: :@scope

      def initialize(params)
        @params = params
        @limit = params[:limit] ? params[:limit].to_i : DEFAULT_LIMIT
        @page = params[:page] ? params[:page].to_i : DEFAULT_PAGE
        @search = params[:search]
        @filters = params[:filters] || {}
        @sort = params[:sort]
        @order = params[:order] ? params[:order] : DEFAULT_ORDER
        @scope = default_scope
      end

      def call
        search_records
        filter_records
        sort_records
      end

      def records
        paginate(scope)
      end

      def all_records
        scope
      end

      def total_count
        default_scope.count
      end

      private

      def default_scope
        raise NotImplementedError
      end

      def filter_records
        raise NotImplementedError
      end

      def sort_records
        scope
      end

      def search_records
        scope
      end

      def paginate(records)
        records.page(page).per(limit)
      end
    end
  end
end
