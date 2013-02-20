table_view
==========

Controller
----------

    @blog_posts = TableView::Table.new(self) do |t|
      t.source { |order| BlogPost.paginate(:order => order, :page => @page, :per_page => per_page) }
      t.column :user, :order => 'CONCAT(`users`.last_name, `users`.first_name)'
      t.column :title
      t.column :created_at, :default => true, :order => '`blog_posts`.created_at', :sort => :desc
    end


View
----

    <%
      table_view(@blog_posts, :class => 'data-table blogs-table') do |t|
        t.column :user, :title => 'Пользователь' do |p|
          link_to(h(p.user.name), :controller => '/users', :action => :show, :id => p.user.id)
        end
    
        t.column :title, :title => 'Тема' do |p|
          link_to(h(truncate_with_ellipsis(p.title, 60)), :action => :show, :id => p.id)
        end
    
        t.column :created_at, :title => 'Дата' do |p|
          text_datetime(p.created_at, false)
        end
      end
    %>
