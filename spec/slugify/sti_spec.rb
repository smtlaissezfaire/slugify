require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module Slugify
  describe "STI" do
    it "should be able to slug a title in a base class" do
      base = BaseClass.new
      base.title = "Foo"
      base.save!
      
      base.reload
      base.slug.should == "foo"
    end
    
    it "should be able to slug a title in the subclass" do
      subclass = SubClass.new
      subclass.title = "Foo"
      subclass.save!
      
      subclass.reload
      subclass.slug.should == "foo"
    end
  end
end
