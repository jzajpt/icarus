require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Backends::Apache do
  before(:all) do
    @apache = Backends::Apache.new
  end
  
  it "should respond to present?" do
    @apache.present?.should == true
  end

  it "should respond to name" do
    @apache.name.should == 'Backends::Apache'
  end  
end