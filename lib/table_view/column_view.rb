module TableView
  class ColumnView
    attr_reader :name, :data, :html_options

    OPTIONS = [ :class, :hint, :data, :title, :simple, :label ]

    def initialize(name, options = {}, &block)
      @name = name.to_s
      @options = options
      @data = (block_given? ? block : @options[:data])
      @html_options = @options.reject { |key, _| OPTIONS.include?(key) }
      @html_options[:class] = class_name
    end

    def class_name
      @class_name ||= @options[:class] || @name
    end

    def title
      @options[:title] || @name
    end

    # Подсказка к столбцу
    def hint
      @options[:hint]
    end

    # Простое поле (без сортировки)
    def simple
      @options[:simple]
    end
  end
end
