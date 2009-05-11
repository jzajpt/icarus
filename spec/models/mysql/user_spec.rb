require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MySQL::User do
  include MysqlHelper

  it "should have table_name class variable" do
    MySQL::User.class_variables.should include('@@table_name')
  end

  describe "attributes" do
    before(:all) do
      @user = MySQL::User.new
    end

    %w(name host password).each do |attr|
      it "should have #{attr} getter" do
        @user.should respond_to(attr)
      end

      it "should have #{attr} setter" do
        @user.should respond_to("#{attr}=")
      end
    end
  end

  it "should respond to create" do
    MySQL::User.should respond_to(:create)
  end

  describe "create with invalid attributes" do
    it "should return nil when empty attributes given" do
      MySQL::User.create('', '', '').should == nil
    end

    it "should return nil when nil attributes given" do
      MySQL::User.create(nil, nil, nil).should == nil
    end

    it "should return nil when malformed attributes given" do
      MySQL::User.create('johnny\'quid', 'password123', 'localhost').should == nil
    end
  end

  describe "create" do
    before(:all) do
      @user = MySQL::User.create('johnnyquid', 'password123', 'localhost')
    end

    after(:all) do
      drop_user 'johnnyquid', 'localhost'
    end

    it "should return User instance" do
      @user.should be_kind_of(MySQL::User)
    end

    it "should set name attribute" do
      @user.name.should == 'johnnyquid'
    end

    it "should set host attribute" do
      @user.host.should == 'localhost'
    end

    it "should set password attribute" do
      @user.password.should_not be_nil
    end

    it "should create user" do
      MySQL::User.find_by_username_and_host('johnnyquid', 'localhost').should_not be_nil
    end
  end

  it "should respond to find_by_username" do
    MySQL::User.should respond_to(:find_by_username)
  end

  describe "find_by_username with invalid attributes" do
    # Not true because username field (User column in user table) can in fact
    # have empty strings and in default instalation exists empty user.

    # it "should return nil when empty attributes given" do
    #   MySQL::User.find_by_username('').should == nil
    # end
    # 
    # it "should return nil when nil attributes given" do
    #   MySQL::User.find_by_username(nil).should == nil
    # end

    it "should return nil when malformed attributes given" do
      MySQL::User.find_by_username('johnny\'quid').should == nil
    end

    it "should return nil when nonexisting database given" do
      MySQL::User.find_by_username('nonexistentdb').should == nil
    end
  end

  describe "find_by_username_and_host" do
    before(:all) do
      @user = MySQL::User.find_by_username('root')
    end

    it "should return MySQL::User instance" do
      @user.should be_kind_of(MySQL::User)
    end

    it "should set name attribute" do
      @user.name.should == 'root'
    end

    it "should set host attribute" do
      @user.host.should be_kind_of(String)
    end

    it "should set password attribute" do
      @user.password.should be_kind_of(String)
    end
  end

  it "should respond to find_by_username_and_host" do
    MySQL::User.should respond_to(:find_by_username_and_host)
  end

  describe "find_by_username_and_host with invalid attributes" do
    it "should return nil when empty attributes given" do
      MySQL::User.find_by_username_and_host('', '').should == nil
    end

    it "should return nil when nil attributes given" do
      MySQL::User.find_by_username_and_host(nil, nil).should == nil
    end

    it "should return nil when malformed attributes given" do
      MySQL::User.find_by_username_and_host('johnny\'quid', 'localhost').should == nil
    end

    it "should return nil when nonexisting database given" do
      MySQL::User.find_by_username_and_host('nonexistentdb', 'localhost').should == nil
    end

    it "should return nil when nonexisting host given" do
      MySQL::User.find_by_username_and_host('mysql', 'nonexistenthost').should == nil
    end
  end

  describe "find_by_username_and_host" do
    before(:all) do
      @user = MySQL::User.find_by_username_and_host('root', 'localhost')
    end

    it "should return MySQL::User instance" do
      @user.should be_kind_of(MySQL::User)
    end

    it "should set name attribute" do
      @user.name.should == 'root'
    end

    it "should set host attribute" do
      @user.host.should == 'localhost'
    end

    it "should set password attribute" do
      @user.password.should be_kind_of(String)
    end
  end

  describe "set_password" do
    before(:all) do
      @username = create_random_user('%')
      @user = MySQL::User.find_by_username_and_host(@username, '%')
    end

    after(:all) do
      drop_user(@username, '%')
    end

    it "should return true" do
      @user.set_password('totallynew').should == true
    end

    it "should change password" do
      previous_password = get_user_password(@username, '%')
      @user.set_password 'newpassword123'
      new_password = get_user_password(@username, '%')
      previous_password.should_not == new_password
    end
  end

  describe "destroy" do
    before(:all) do
      @username = create_random_user('%')
      @user = MySQL::User.find_by_username_and_host(@username, '%')
    end

    it "should return true" do
      @user.destroy.should == true
    end

    it "should destroy user" do
      attrs = MysqlAdapter.select_one "SELECT User from mysql.user WHERE User = '#{@username}' and Host = '%'"
      attrs.should be_nil
    end
  end

  describe "instance" do
    before(:all) do
      @user = MySQL::User.new
    end

    it "should respond to destroy" do
      @user.should respond_to(:set_password)
    end

    it "should respond to destroy" do
      @user.should respond_to(:destroy)
    end
  end
end
