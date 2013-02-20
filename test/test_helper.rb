require 'rubygems'
require 'test/unit'

gem 'activerecord', '<=2.3.9'
gem 'activesupport', '<=2.3.9'
gem 'actionpack', '<=2.3.9'

require 'active_record'
require 'active_support'
require 'active_support/test_case'
require 'action_controller'
require 'action_controller/test_case'

Dir["lib/**/*.rb"].each { |file| require file }
require 'init.rb'


ActionController::Base.view_paths = [ 'test/app/views' ]
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false
# ActiveRecord::Base.logger = Logger.new($stdout)
# ActiveRecord::Base.logger.level = Logger::DEBUG

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string :login
      t.string :email
      t.boolean :change
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class User < ActiveRecord::Base
  def mail; email; end
end

class UsersController < ActionController::Base
  def index
    @users = TableView::Table.new(self) do |t|
      t.source { |order| User.all(:order => order) }
      t.column :login
      t.column :email
      t.column :change
    end
  end
end

ActionController::Routing::Routes.draw do |map|
  map.user '/users/show/:id', :controller => 'users', :action => 'show'
  map.connect ':controller/:action/:id'
end
