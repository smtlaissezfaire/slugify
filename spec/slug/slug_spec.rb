require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Slug do
  before do
    User.delete_all
    Page.delete_all
    SlugColumn.delete_all
    Scope.delete_all
  end

  describe ActiveRecord::Base do
    it "should respond_to? :slugify" do
      ActiveRecord::Base.should respond_to(:slugify)
    end
  end

  class User < ActiveRecord::Base
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
      slugify :title
    end

    it "should allow a different name" do
      p = Page.new(:title => "foo")
      p.generate_slug
      p.slug.should == "foo"
    end

    class SlugColumn < ActiveRecord::Base
      slugify :foo, :slug_column => "url_slug"
    end

    it "should allow a different slug column" do
      s = SlugColumn.new(:foo => "bar")
      s.generate_slug
      s.url_slug.should == "bar"
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

    it "should not regenerate the slug on update" do
      u = create_user(:name => "scott")
      u.save!
      u.name = "foo"
      u.save!

      u.slug.should == "scott"
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
end
