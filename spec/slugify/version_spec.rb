require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module Slugify
  describe VERSION do
    it "should be at 0.1.0" do
      Slugify::VERSION.should == "0.1.0"
    end
  end
end
