require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'digest/sha2'

describe Backends::System do
  before(:all) do
    @system = Backends::System.new
  end

  it "should respond to present? with true" do
    @system.present?.should == true
  end

  it "should respond to name with backend name" do
    @system.name.should == 'Backends::System'
  end

  it "should respond to echo" do
    @system.should respond_to(:echo)
  end

  it "should have echo working service" do
    random_hash = Digest::SHA2.hexdigest("#{Time.now}--#{rand}")
    @system.echo(random_hash).should == random_hash
  end

  it "should respond to ping" do
    @system.should respond_to(:ping)
  end

  it "should have working ping" do
    @system.ping.should == 'pong'
  end

  it "should respond to uname" do
    @system.should respond_to(:uname)
  end

  it "should respond to uname by returning uname" do
    @system.uname.should == `uname -a`
  end

  it "should respond to uptime" do
    @system.should respond_to(:uptime)
  end

  it "should respond to uptime by returning uptime" do
    Sys::Uptime.stub!(:uptime).and_return('1:1:1:1')
    @system.uptime.should == '1:1:1:1'
  end

  it "should respond to user_exists?" do
    @system.should respond_to(:user_exists?)
  end

  describe "user_exits?" do
    it "should return true when user exists" do
      Sys::Admin.should_receive(:get_user).and_return(true)
      @system.user_exists?('bogus-testing-username').should == true
    end

    it "should return false when user doesn't exist" do
      Sys::Admin.should_receive(:get_user).and_raise(Sys::Admin::Error)
      @system.user_exists?('bogus-testing-username').should == false
    end
  end

  it "should respond to group_exists?" do
    @system.should respond_to(:group_exists?)
  end

  describe "group_exits?" do
    it "should return true when group exists" do
      Sys::Admin.should_receive(:get_group).and_return(true)
      @system.group_exists?('bogus-testing-group').should == true
    end

    it "should return false when group doesn't exist" do
      Sys::Admin.should_receive(:get_group).and_raise(Sys::Admin::Error)
      @system.group_exists?('bogus-testing-groupname').should == false
    end
  end
end
