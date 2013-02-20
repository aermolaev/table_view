module TableView
  class Columns
    def initialize
      @columns = {}
    end

    def [](name)
      @columns[name] || default
    end

    def <<(column)
      name = column.name
      @first_name ||= name
      @default = column if column.default
      @columns[name] = column
    end

    def default
      @default ||= @columns[@first_name]
    end
  end
end
