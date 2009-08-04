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
    end

    attr_reader :source_slug_column
    attr_reader :slug_column

  private

    def default_slug_options
      {
        :slug_column => :slug,
        :scope       => []
      }
    end
  end

  module InstanceMethods
    def generate_slug
      slug_value = send(source_slug_column)

      if !slug_value.blank?
        slug_value = slug_value.dup
        slug_value.downcase!
        slug_value.gsub! /[\'\"\#\$\,\.\!\?\%\@\(\)]+/, ''
        slug_value.gsub! /\&/,                          'and'
        slug_value.gsub! /\_/,                          '-'
        slug_value.gsub! /(\s+)|[\_]/,                  '-'
        slug_value.gsub! /(\-)+/,                       '-'
        original_slug_value = slug_value

        counter = 0

        while true
          if self.class.count(:conditions => ["#{slug_column} = ?", slug_value]) == 0
            send("#{slug_column}=", slug_value)
            break
          else
            slug_value = "#{original_slug_value}-#{counter}"
            counter += 1
          end
        end
      end
    end

  private

    def source_slug_column
      self.class.source_slug_column
    end

    def slug_column
      self.class.slug_column
    end
  end
end
