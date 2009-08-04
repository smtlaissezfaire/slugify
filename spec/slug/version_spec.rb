require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module Slug
  describe VERSION do
    it "should be at 0.0.1" do
      Slug::VERSION.should == "0.0.1"
    end
  end
end
