require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Apache::Section do
  context "empty section" do
    before(:all) do
      @section = Apache::Section.new
    end

    it "should respond to :name" do
      @section.should respond_to(:name)
    end
    
    it "should respond to :value" do
      @section.should respond_to(:value)
    end
  
    it "should respond to :directives" do
      @section.should respond_to(:directives)
    end
    
    it "should respond to :sections" do
      @section.should respond_to(:sections)
    end

    it "should respond to :has_directive?" do
      @section.should respond_to(:has_directive?)
    end

    it "should respond to :find_directive_by_name" do
      @section.should respond_to(:find_directive_by_name)
    end

    it "should have empty array of directives" do
      @section.directives.should be_kind_of(Array)
    end
  end
  
  context "section with directives" do
    before(:all) do
      @section = Apache::Section.new
    end
  end
end
