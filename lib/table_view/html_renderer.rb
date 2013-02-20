module TableView
  class HTMLRenderer
    attr_reader :table, :helpers
    delegate :link_to, :link_to_remote, :tag, :to => :helpers

    OPTIONS = [ :no_colgroup, :no_thead, :ajax_update ]
    EMPTY_PROC = lambda { |_| nil }

    def initialize(helpers, table, options)
      @helpers = helpers
      @table = table
      @options = options || {}
      @columns = []

      yield(self) if block_given?
    end

    def column(*args, &block)
      @columns << TableView::ColumnView.new(*args, &block)
    end

    def row(&block)
      @row = block
    end

    def url_for(&block)
      @url_for = block
    end

    def header_cell(&block)
      @header_cell = block
    end

    def colgroup_tag
      content_tag('colgroup', yield)
    end

    def thead_tag
      content_tag('thead', yield)
    end

    def tbody_tag
      content_tag('tbody', yield)
    end

    def to_str
      content = content_tag('table', colgroup + thead + tbody, html_table_options)

      if ajax_update && !table.controller.request.xhr?
        content_tag('div', content, :id => ajax_update)
      else
        content
      end
    end

    protected

    def content_tag(name, content, options = nil)
      # return helpers.send(:content_tag_string, name, content, options)
      attrs = ''
      options.each_pair { |k, v| attrs << %( #{k}="#{ERB::Util.h(v)}") if v } if options.present?
      "<#{name}#{attrs}>#{content}</#{name}>".html_safe
    end

    def row_options
      @row || EMPTY_PROC
    end

    def header_cell_options
      @header_cell || EMPTY_PROC
    end

    def html_table_options
      @options.reject { |key, _| OPTIONS.include?(key.to_sym) }
    end

    def columns
      @columns.map { |column| yield(column) }
    end

    def colgroup
      return '' if @options[:no_colgroup]

      colgroup_tag do
        columns { |column| col(column) }
      end
    end

    def thead
      return '' if @options[:no_thead]

      thead_tag do
        content_tag('tr', columns { |column| th(column) })
      end
    end

    def tbody
      tbody_tag do
        table.data.map { |item| tr(item) }
      end
    end

    def tr(item)
      content = columns { |column| td(column, item) }
      content_tag('tr', content, row_options.call(item))
    end

    def col(column)
      tag(:col, :class => column.class_name)
    end

    def th(column)
      title = "#{column.title}".html_safe
      class_names = [ column.class_name ]
      method = column.simple ? :th_simple : :th_ordered

      send(method, column, title, class_names)
    end

    def th_hint(column, title, class_names)
      if column.hint
        class_names << 'hinted'
        content = content_tag('i', column.hint, :class => 'hint-content')

        title << tag(:br)
        title << content_tag('span', content, :class => 'hint')
      end
    end

    def th_simple(column, title, class_names)
      th_hint(column, title, class_names)
      content = content_tag('span', title, :class => 'title')
      th_render(column, content, class_names)
    end

    def th_ordered(column, title, class_names)
      this = (column.name == table.order)

      th_hint(column, title, class_names)

      if this
        class_names << 'ordered'
        class_names << table.order_column.send(table.asc ? :sort : :sort_reverse)
      end

      order = column.name if column.name != table.order_default
      sort = (table.asc ? 1 : nil) if this
      params = { :order => order, :sort => sort }

      content = if ajax_update
        params[:action] = ajax_update
        link_to_remote(title, :url => url_for_sort(params), :update => ajax_update, :method => :get, :html => { :class => 'link' })
      else
        link_to(title, url_for_sort(params), :class => 'link')
      end

      th_render(column, content, class_names)
    end

    def th_render(column, content, class_names)
      options = { :class => class_names * ' ' }
      options = options.merge!(header_cell_options.call(column) || {})
      content_tag('th', content, options)
    end

    def td(column, item)
      # если данные не указаны, то используется название для вызова метода
      value = if column.data
        column.data.call(item)
      else
        ERB::Util.h(item.send(column.name))
      end

      content_tag('td', value, column.html_options)
    end

    def url_for_sort(options = {})
      opts = table.params.merge(options)

      # удаляем параметр для пейджера
      opts.delete(:page)

      if @url_for
        @url_for.call(opts)
      else
        helpers.url_for(opts)
      end
    end

    def ajax_update
      @options[:ajax_update]
    end
  end
end
