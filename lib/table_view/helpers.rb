module TableView
  module Helpers
    def table_view(table, options = {}, &block)
      concat(TableView::HTMLRenderer.new(self, table, options, &block).to_str)
    end

    def table_view_csv(table, options = {}, &block)
      concat(TableView::CSVRenderer.new(self, table, options, &block).to_str)
    end
  end
end
