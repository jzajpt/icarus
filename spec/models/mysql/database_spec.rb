require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MySQL::Database do
  include MysqlHelper

  describe "attributes" do
    before(:all) do
      @user = MySQL::Database.new
    end

    %w(name character_set).each do |attr|
      it "should have #{attr} getter" do
        @user.should respond_to(attr)
      end

      it "should have #{attr} setter" do
        @user.should respond_to("#{attr}=")
      end
    end
  end

  it "should respond to create" do
    MySQL::Database.should respond_to(:create)
  end

  describe "create with invalid attributes" do
    it "should return nil when empty name given" do
      MySQL::Database.create('').should == nil
    end

    it "should return nil when empty attributes given" do
      MySQL::Database.create('', nil).should == nil
    end

    it "should return nil when nil attributes given" do
      MySQL::Database.create(nil, nil).should == nil
    end

    it "should return nil when malformed attributes given" do
      MySQL::Database.create('johnny\'quid', 'utf8"').should == nil
    end
  end

  it "should respond to find_all" do
    MySQL::Database.should respond_to(:find_all)
  end

  describe "find_all" do
    before(:all) do
      @databases = MySQL::Database.find_all
    end

    it "should return an array" do
      @databases.should be_kind_of(Array)
    end

    it "should place Database instances inside an array" do
      @databases.each do |database|
        database.should be_kind_of(MySQL::Database)
      end
    end

    it "should set name attribute on each instance" do
      @databases.each do |database|
        database.name.should be_kind_of(String)
      end
    end
  end

  describe "create" do
    before(:all) do
      @user = MySQL::Database.create('johnnyquid_cz', 'utf8')
    end

    after(:all) do
      drop_database 'johnnyquid_cz'
    end

    it "should return Database instance" do
      @user.should be_kind_of(MySQL::Database)
    end
  end

  it "should respond to find_by_name" do
    MySQL::Database.should respond_to(:find_by_name)
  end

  describe "find_by_name with invalid attributes" do
    it "should return nil when malformed attributes given" do
      MySQL::Database.find_by_name('johnny\'quid').should == nil
    end

    it "should return nil when nonexisting database given" do
      MySQL::Database.find_by_name('nonexistentdb').should == nil
    end
  end

  describe "find_by_name" do
    before(:all) do
      @database = MySQL::Database.find_by_name('test')
    end

    it "should return MySQL::Database instance" do
      @database.should be_kind_of(MySQL::Database)
    end

    it "should set name attribute" do
      @database.name.should == 'test'
    end

    # it "should set character set" do
    #   @database.character_set.should be_kind_of(String)
    # end
  end

  describe "grant_all_to" do
    before(:all) do
      @user_name = create_random_user
      @db_name = create_random_database
      @database = MySQL::Database.find_by_name(@db_name)
    end

    after(:all) do
      drop_user @user_name, 'localhost'
      drop_database @db_name
    end

    it "should return false when nil is specified as user" do
      @database.grant_all_to(nil).should == false
    end

    it "should return true when given user instance" do
      @user = MySQL::User.find_by_username(@user_name)
      @database.grant_all_to(@user).should == true
    end
  end

  describe "size" do
    before(:all) do
      @database = MySQL::Database.find_by_name('mysql')
      @size = @database.size
    end

    it "should return integer" do
      @size.should be_kind_of(Numeric)
    end
  end

  describe "destroy" do
    before(:all) do
      @name = create_random_database
      @database = MySQL::Database.find_by_name(@name)
    end

    it "should return true" do
      @database.destroy.should == true
    end

    it "should destroy database" do
      database_exists?(@name).should == false
    end
  end

  describe "instance" do
    before(:all) do
      @database = MySQL::Database.new
    end

    it "should respond to grant_all_to" do
      @database.should respond_to(:grant_all_to)
    end

    it "should respond to size" do
      @database.should respond_to(:size)
    end

    it "should respond to destroy" do
      @database.should respond_to(:destroy)
    end
  end

end