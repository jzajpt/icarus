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

  it "should respond to create_domain" do
    @apache.should respond_to(:create_domain)
  end

  it "should respond to destroy_subdomain" do
    @apache.should respond_to(:destroy_subdomain)
  end
  
  it "should respond to domain_exists?" do
    @apache.should respond_to(:domain_exists?)
  end

  it "should respond to create_subdomain" do
    @apache.should respond_to(:create_subdomain)
  end

  it "should respond to update_subdomain" do
    @apache.should respond_to(:update_subdomain)
  end
  
  it "should respond to destroy_subdomain" do
    @apache.should respond_to(:destroy_subdomain)
  end
  
  it "should respond to subdomain_exists?" do
    @apache.should respond_to(:subdomain_exists?)
  end
end