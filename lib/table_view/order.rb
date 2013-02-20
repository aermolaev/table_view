module TableView
  # Порядок сортировки данных
  class Order
    attr_reader :column, :asc, :sorting

    def initialize(col, asc)
      @column = col
      @asc = asc
      @sorting = asc ? @column.sort : @column.sort_reverse
    end

    def to_s
      (@table ? "`#{@table}`." : '') + "#{column.order} #{sorting.to_s.upcase}"
    end

    # order.table('test').to_s
    #   -> `test`.`column` ASC
    def table(name)
      @table = name
      self
    end
  end
end

module Arel
  module Visitors
    class ToSql
      private

      def visit_TableView_Order o
        o.to_s
      end
    end
  end
end