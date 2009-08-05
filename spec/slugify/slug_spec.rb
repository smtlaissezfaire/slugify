require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Slugify do
  describe ActiveRecord::Base do
    it "should not automatically mix in the module" do
      ActiveRecord::Base.included_modules.should_not include(Slugify)
    end
  end

  class User < ActiveRecord::Base
    include Slugify

    validates_presence_of :name
    slugify :name
  end

  def new_user(attributes = {})
    User.new(attributes)
  end

  def create_user(attributes={})
    u = new_user(attributes)
    u.save!
    u
  end

  describe "slug generation" do
    it "should be able to slugify the column" do
      u = new_user(:name => "foo")
      u.generate_slug
      u.slug.should == "foo"
    end

    it "should use the correct name given" do
      u = new_user(:name => "bar")
      u.generate_slug
      u.slug.should == "bar"
    end

    class Page < ActiveRecord::Base
      include Slugify

      slugify :title
    end

    it "should allow a different name" do
      p = Page.new(:title => "foo")
      p.generate_slug
      p.slug.should == "foo"
    end

    class SlugColumn < ActiveRecord::Base
      include Slugify

      slugify :foo, :slug_column => "url_slug"
    end

    it "should allow a different slug column" do
      s = SlugColumn.new(:foo => "bar")
      s.generate_slug
      s.url_slug.should == "bar"
    end
  end

  describe "slug escaping" do
    it "should replace uppercase with lowercase" do
      u = new_user(:name => "Scott")
      u.generate_slug
      u.slug.should == "scott"
    end

    ["'",
     '"',
     '#',
     '$',
     ',',
     '.',
     '!',
     '?',
     '%',
     '@',
     '(',
     ')'].each do |punct|
      it "should strip out the punctuation mark '#{punct}'" do
        u = new_user(:name => "a#{punct}")
        u.generate_slug
        u.slug.should == "a"
      end
    end

    it "should replace a space with a dash" do
      u = new_user(:name => "Scott Taylor")
      u.generate_slug
      u.slug.should == "scott-taylor"
    end

    it "should replace multiple spaces with one dash" do
      u = new_user(:name => "Scott       Taylor")
      u.generate_slug
      u.slug.should == "scott-taylor"
    end

    it "should replace ampersand with 'and'" do
      u = new_user(:name => "One & Two")
      u.generate_slug
      u.slug.should == "one-and-two"
    end

    it "should replace the underscore with a dash" do
      u = new_user(:name => "one_two")
      u.generate_slug
      u.slug.should == "one-two"
    end

    it "should replace non-word chars with dashes" do
      u = new_user(:name => "one\ntwo")
      u.generate_slug
      u.slug.should == "one-two"
    end

    it "should keep a dash" do
      u = new_user(:name => "one-two")
      u.generate_slug
      u.slug.should == "one-two"
    end

    it "should replace multiple dashes" do
      u = new_user(:name => "one--two")
      u.generate_slug
      u.slug.should == "one-two"
    end
  end

  it "should not generate a slug if the source column is nil" do
    u = new_user(:name => nil)
    u.generate_slug
    u.slug.should be_nil
  end

  it "should not generate a slug if the source column is empty" do
    u = new_user(:name => "")
    u.generate_slug.should be_nil
  end

  describe "generating the slug when one already exists" do
    it "should create a slug with -0 appended on to it" do
      create_user(:name => "Scott Taylor")
      create_user(:name => "Scott Taylor").slug.should == "scott-taylor-0"
    end

    it "should create a slug with -1 appended to it when it is the third slug" do
      create_user(:name => "Scott Taylor")
      create_user(:name => "Scott Taylor")
      create_user(:name => "Scott Taylor").slug.should == "scott-taylor-1"
    end
  end

  describe "scopes" do
    class Scope < ActiveRecord::Base
      include Slugify
      slugify :title, :scope => :some_id
    end

    def create_scope(attrs={})
      s = Scope.new(attrs)
      s.save!
      s
    end

    it "should generate unique identifiers in the same scope" do
      one = create_scope(:title => "foo", :some_id => 1)
      two = create_scope(:title => "foo", :some_id => 1)

      one.slug.should == "foo"
      two.slug.should == "foo-0"
    end

    it "should allow a slug to be scoped (so that the same slug can be used in different contexts" do
      first  = create_scope(:title => "one", :some_id => 1)
      second = create_scope(:title => "one", :some_id => 2)
      
      first.slug.should == "one"
      second.slug.should == "one"
    end
  end

  describe "scoped by two columns" do
    class MultiScope < ActiveRecord::Base
      include Slugify
      slugify :title, :scope => [:scope_one, :scope_two]
    end

    def create_scope(attrs={})
      s = MultiScope.new(attrs)
      s.save!
      s
    end

    it "show generate a unique identifier in the same scopes" do
      first  = create_scope(:title => "one", :scope_one => 1, :scope_two => 1)
      second = create_scope(:title => "one", :scope_one => 1, :scope_two => 1)
      
      first.slug.should == "one"
      second.slug.should == "one-0"
    end

    it "should use the same identifier in different scopes" do
      first  = create_scope(:title => "one", :scope_one => 1, :scope_two => 1)
      second = create_scope(:title => "one", :scope_one => 1, :scope_two => 2)

      first.slug.should == "one"
      second.slug.should == "one"
    end
  end

  describe "validations" do
    it "should generate the slug on creation" do
      u = create_user(:name => "scott")
      u.slug.should == "scott"
    end

    it "should not generate the slug if not valid" do
      u = User.new(:name => "")
      u.should_not be_valid

      u.should_not_receive(:generate_slug)
      u.valid?
    end

    describe "with a :when lambda" do
      class SlugWithProc < ActiveRecord::Base
        include Slugify

        slugify :title, :when => lambda { |obj| obj.a_value }
   
        attr_accessor :a_value
      end
   
      it "should allow slug generation when the proc is true" do
        s = SlugWithProc.new(:title => "foo")
        s.a_value = true

        s.generate_slug
        s.slug.should == "foo"
      end

      it "should not allow slug generation when the slug is false" do
        s = SlugWithProc.new(:title => "foo")
        s.a_value = false

        s.generate_slug
        s.slug.should be_nil
      end

      it "should allow slug generation when the value is truthy" do
        s = SlugWithProc.new(:title => "foo")
        s.a_value = "a-truthy-value"

        s.generate_slug
        s.slug.should == "foo"
      end

      it "should not allow slug generation when the value is falsy (i.e. nil)" do
        s = SlugWithProc.new(:title => "foo")
        s.a_value = nil

        s.generate_slug
        s.slug.should be_nil
      end
    end

    describe "rerunning slug generation" do
      it "should not regenerate the slug on update (by default)" do
        u = create_user(:name => "scott")
        u.save!
        u.name = "foo"
        u.save!

        u.slug.should == "scott"
      end

      it "should not regenerate the slug if the slug already exists" do
        u = User.new(:slug => "foo", :name => "foo")
        
        u.name = "Bar"
        u.generate_slug
        
        u.slug.should == "foo"
      end

      it "should regenerate the slug if the slug is nil" do
        u = User.new(:slug => nil, :name => "foo")

        u.name = "Bar"
        u.generate_slug
        
        u.slug.should == "bar"
      end

      it "should regenerate the slug if the slug is the empty string" do
        u = User.new(:slug => "", :name => "foo")
        
        u.name = "bar"
        u.generate_slug
        
        u.slug.should == "bar"
      end
    end

    describe "html escaping" do
      it "should strip html" do
        pending do
          u = User.new
          u.name = "&lt;p&gt;&lt;i&gt;the silence before bach&lt;/i&gt;&lt;/p&gt;"
          u.generate_slug
          u.slug.should == "the-silence-before-bach"
        end
      end
    end

    describe "utf8-chars" do
      it "should replace them" do
        u = User.new(:name => "cinqüenta")
        u.generate_slug
        u.slug.should == "cinquenta"
      end
    end
    
    describe "passing invalid options" do
      it "should raise an error, displaying the valid keys" do
        lambda {
          Class.new do
            def self.before_save(*args); end
            
            include Slugify
            slugify :foo, :source_column => :bar
          end
        }.should raise_error(ArgumentError, "Unknown key(s): source_column")
      end
      
      it "should symbolize keys" do
        obj = Class.new do
          def self.before_save(*args); end
            include Slugify

            slugify "col", "slug_column" => "foo", "scope" => "bar", "when" => "baz"
        end
        
        obj.source_slug_column.should == "col"
        obj.slug_column.should == "foo"
        obj.slug_scope.should == "bar"
        obj.slugify_when.should == "baz"
      end
    end
  end
end
