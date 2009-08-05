require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class UnusedSlugifyClass < ActiveRecord::Base
  include Slugify
end

describe "including", Slugify do
  it "should not raise an error if included into a class and the class does not call slugify" do
    lambda {
      UnusedSlugifyClass.create!
    }.should_not raise_error
  end
end