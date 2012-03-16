require File.expand_path(File.dirname(__FILE__) + "/slugify/slug_generator")

module Slugify
  def self.append_features(other)
    other.extend ClassMethods
  end

  module ClassMethods
    def slugify(source_slug_column, options_given={})
      before_save :generate_slug

      options_given.symbolize_keys!

      options_given.assert_valid_keys(*default_slug_options.keys)

      options = default_slug_options.merge(options_given)
      options[:scope] = [options[:scope]] unless options[:scope].respond_to?(:[])

      class_attribute :source_slug_column
      class_attribute :slug_column
      class_attribute :slug_scope
      class_attribute :slugify_when

      self.source_slug_column = source_slug_column
      self.slug_column        = options[:slug_column]
      self.slug_scope         = options[:scope]
      self.slugify_when       = options[:when]

      include InstanceMethods
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

    def to_param
      read_attribute(self.class.slug_column)
    end
  end
end