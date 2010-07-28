require File.expand_path(File.dirname(__FILE__) + "/slugify/version")
require File.expand_path(File.dirname(__FILE__) + "/slugify/slug_generator")

module Slugify
  VERSION = Version::STRING

  def self.append_features(other)
    other.extend ClassMethods
    other.class_eval do
      include InstanceMethods
    end
  end

  module ClassMethods
    def slugify(source_slug_column, options_given={})
      before_save :generate_slug

      options_given.symbolize_keys!

      options_given.assert_valid_keys(*default_slug_options.keys)

      options = default_slug_options.merge(options_given)
      options[:scope] = [options[:scope]] unless options[:scope].respond_to?(:[])

      class_inheritable_accessor :source_slug_column
      class_inheritable_accessor :slug_column
      class_inheritable_accessor :slug_scope
      class_inheritable_accessor :slugify_when

      self.source_slug_column = source_slug_column
      self.slug_column        = options[:slug_column]
      self.slug_scope         = options[:scope]
      self.slugify_when       = options[:when]
    end

  private

    def default_slug_options
      {
        :slug_column  => :slug,
        :scope        => [],
        :when         => lambda { |obj| obj.new_record? }
      }
    end
  end

  module InstanceMethods
    def generate_slug
      Slugify::SlugGenerator.generate(self)
    end

    def regenerate_slug
      Slugify::SlugGenerator.regenerate(self)
    end
  end
end
