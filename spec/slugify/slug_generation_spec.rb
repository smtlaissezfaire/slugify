require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module Slugify
  describe SlugGenerator do
    it "should generate slug" do
      Slugify::SlugGenerator.generate_slug("Foo Bar").should == "foo-bar"
    end
  end
end