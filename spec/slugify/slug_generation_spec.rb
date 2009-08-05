require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module Slugify
  describe SlugGenerator do
    it "should generate slug" do
      Slugify::SlugGenerator.clean("Foo Bar").should == "foo-bar"
    end
  end
end