require File.expand_path(File.dirname(__FILE__) + "/slug/slug_generator")

module Slug
  def self.included(other)
    other.extend ClassMethods
    other.class_eval do
      before_create :generate_slug
      include InstanceMethods
    end
  end

  module ClassMethods
    def slugify(source_slug_column, options_given={})
      options = default_slug_options.merge(options_given)
      
      @source_slug_column = source_slug_column
      @slug_column        = options[:slug_column]
      @slug_scope         = options[:scope]
    end
    
    attr_reader :source_slug_column
    attr_reader :slug_column
    attr_reader :slug_scope
    
  private
    
    def default_slug_options
      {
        :slug_column => :slug,
        :scope       => nil
      }
    end
  end

  module InstanceMethods
    def generate_slug
      SlugGenerator.generate_slug(self)
    end
  end
end
