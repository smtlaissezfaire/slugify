class User < ActiveRecord::Base
  include Slugify

  validates_presence_of :name
  slugify :name
end

class Page < ActiveRecord::Base
  include Slugify

  slugify :title
end

class SlugColumn < ActiveRecord::Base
  include Slugify

  slugify :foo, :slug_column => "url_slug"
end

class Scope < ActiveRecord::Base
  include Slugify
  slugify :title, :scope => :some_id
end

class MultiScope < ActiveRecord::Base
  include Slugify
  slugify :title, :scope => [:scope_one, :scope_two]
end

class SlugWithProc < ActiveRecord::Base
  include Slugify

  slugify :title, :when => lambda { |obj| obj.a_value }

  attr_accessor :a_value
end

class UnusedSlugifyClass < ActiveRecord::Base
  include Slugify
end

class BaseClass < ActiveRecord::Base
  include Slugify
  slugify :title
end

class SubClass < BaseClass
end

