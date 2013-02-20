module TableView
  class Table
    attr_reader :params, :options, :columns, :controller
    delegate :length, :to => :data

    def initialize(controller = nil)
      @source = nil
      @controller = controller
      @params = controller.request.params rescue {}
      @columns = TableView::Columns.new

      yield(self) if block_given?
    end

    # данные
    def data
      @data ||= @source[TableView::Order.new(order_column, asc)]
    end

    # источник данных
    #
    # table.source { |order| User.all(:order => order) }
    def source(&block)
      @source = block
    end

    def column(*args)
      @columns << TableView::Column.new(*args)
    end

    def order_column
      @order_column ||= @columns[@params[:order]]
    end

    def order
      order_column.name
    end

    def order_default
      @order_default ||= @columns.default.name
    end

    def asc
      @params[:sort].to_i != 1
    end

    def desc
      !asc
    end

    def inspect
      "#<#{self.class.name}>"
    end
  end
end
