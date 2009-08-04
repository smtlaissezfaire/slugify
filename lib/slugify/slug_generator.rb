module Slugify
  class SlugGenerator
    def self.generate_slug(obj)
      new(obj).generate_slug
    end

    def initialize(obj)
      @obj = obj
    end

    def generate_slug
      if generate_slug?
        slug_value = source_slug_value
   
        if !slug_value.blank?
          set_unique_slug_value(cleanup_slug(slug_value.dup))
        end
      end
    end

    def generate_slug?
      !slug_exists? &&
        slugify_proc.call(@obj) ? true : false
    end

    def slug_exists?
      !slug.blank?
    end

  private

    def build_conditions(slug_value)
      conditions = { slug_column => slug_value }
      scopes.each do |column_name|
        conditions[column_name] = scope_value(column_name)
      end
      conditions
    end

    def cleanup_slug(slug_value)
      slug_value.downcase!
      slug_value.gsub! /[\'\"\#\$\,\.\!\?\%\@\(\)]+/, ''
      slug_value.gsub! /\&/,                          'and'
      slug_value.gsub! /\_/,                          '-'
      slug_value.gsub! /(\s+)|[\_]/,                  '-'
      slug_value.gsub! /(\-)+/,                       '-'
      slug_value
    end

    def set_unique_slug_value(slug_value)
      original_slug_value = slug_value
      counter = 0

      while true
        if count(:conditions => build_conditions(slug_value)) == 0
          self.slug = slug_value
          break
        else
          slug_value = "#{original_slug_value}-#{counter}"
          counter += 1
        end
      end
    end

    def scope?
      scope ? true : false
    end

    def scopes
      @obj.class.slug_scope
    end

    def scope_value(scope_column)
      @obj.send(scope_column)
    end

    def slug
      @obj.send(slug_column)
    end

    def slug=(value)
      @obj.send("#{slug_column}=", value)
    end

    def count(*args)
      @obj.class.count(*args)
    end

    def source_slug_value
      @obj.send(source_slug_column)
    end

    def source_slug_column
      @obj.class.source_slug_column
    end

    def slug_column
      @obj.class.slug_column
    end

    def slugify_proc
      @obj.class.slugify_when
    end
  end
end