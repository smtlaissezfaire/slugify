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
    t.string :title
    t.string :some_id
    t.string :slug
  end
end
