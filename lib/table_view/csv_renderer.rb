module TableView
  class CSVRenderer
    require 'fastercsv'

    attr_reader :table, :helpers

    OPTIONS = [ :no_head ]

    def initialize(helpers, table, options)
      @helpers = helpers
      @table = table
      @options = options || {}
      @options[:col_sep] ||= ';'
      @columns = []

      yield(self) if block_given?
    end

    def column(*args, &block)
      @columns << TableView::ColumnView.new(*args, &block)
    end

    def to_str
      FasterCSV.generate(cvs_table_options) do |csv|
        csv << head
        lines(csv)
      end
    end

    protected

    def cvs_table_options
      @options.reject { |key, _| OPTIONS.include?(key.to_sym) }
    end

    def columns
      @columns.map { |column| yield(column) }
    end

    def head
      return '' if @options[:no_head]

      columns { |column| title(column) }
    end

    def lines(csv)
      table.data.map { |item|
        csv << columns { |column| cell(column, item) }
      }
    end

    def title(column)
      helpers.strip_tags(column.title).gsub('&#160;', ' ')
    end

    def cell(column, item)
      if column.data
        column.data.call(item)
      else
        item.send(column.name)
      end
    end
  end
end