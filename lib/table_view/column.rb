module TableView
  class Column
    attr_reader :name

    def initialize(name, options = {})
      @name = name.to_s
      @options = options
    end

    # SQL для сортировки
    def order
      @order ||= (@options[:order] || "`#{@name}`")
    end

    # Поле по умолчанию
    def default
      @default ||= (@options[:default] ? true : false)
    end

    # Тип сортировки по умолчанию
    def sort
      @sort ||= (@options[:sort] || :asc).to_sym
    end

    # Тип сортировки в обратном порядке
    def sort_reverse
      @sort_reverse ||= (sort == :asc ? :desc : :asc)
    end
  end
end
