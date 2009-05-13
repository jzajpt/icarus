require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Apache::Directive do
  context "empty directive" do
    before(:all) do
      @directive = Apache::Directive.new
    end

    it "should respond to :name" do
      @directive.should respond_to(:name)
    end
  
    it "should respond to :value" do
      @directive.should respond_to(:value)
    end
  end
end
