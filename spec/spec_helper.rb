require 'rubygems'
require 'activerecord'

require File.expand_path(File.dirname(__FILE__) + "/../lib/slug")
require File.expand_path(File.dirname(__FILE__) + "/../init")

require 'sqlite3'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database  => ':memory:'
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.string :name
    t.string :slug
  end

  create_table :pages do |t|
    t.string :title
    t.string :slug
  end

  create_table :slug_columns do |t|
    t.string :foo
    t.string :url_slug
  end

  create_table :scopes do |t|
    t.string  :title
    t.string  :slug
    t.integer :some_id
  end
  
  create_table :multi_scopes do |t|
    t.string :title
    t.string :slug
    t.string :scope_one
    t.string :scope_two
  end
  
  create_table :slug_with_procs do |t|
    t.string :title
    t.string :slug
  end
end

Spec::Runner.configure do |config|
  config.before :each do
    cleanup_db
  end

  def cleanup_db
    User.delete_all
    Page.delete_all
    SlugColumn.delete_all
    Scope.delete_all
    MultiScope.delete_all
    SlugWithProc.delete_all
  end
end
