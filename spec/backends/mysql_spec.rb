require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Backends::Mysql do
  include MysqlHelper

  before(:all) do
    @mysql = Backends::Mysql.new
  end

  it "should respond to present?" do
    @mysql.present?.should == true
  end

  it "should respond to name" do
    @mysql.name.should == 'Backends::Mysql'
  end

  it "should respond to create_user" do
    @mysql.should respond_to(:create_user)
  end

  describe "create_user" do  
    it "should return false when malformed user name specified" do
      @mysql.create_user("'malformedname", 'password123', 'localhost').should == false
    end

    it "should return false when duplicate user name specified" do
      @name = create_random_user
      @mysql.create_user(@name, 'password123', 'localhost').should == false
      drop_user(@name, 'localhost')
    end

    it "should return true when valid parameters specified" do
      @name = "test#{rand(10000)}"
      @mysql.create_user(@name, 'password123', 'localhost').should == true
      drop_user(@name, 'localhost')
    end
  end

  it "should respond to create_database" do
    @mysql.should respond_to(:create_database)
  end

  describe "create_database" do  
    it "should return false when malformed database name specified" do
      @mysql.create_database("'malformedname", 'utf8').should == false
    end

    it "should return false when duplicate database name specified" do
      @name = create_random_database
      @mysql.create_database(@name, 'utf8').should == false
      drop_database @name
    end

    it "should return true when valid name and charset specified" do
      @name = "test#{rand(1000)}"
      @mysql.create_database(@name, 'utf8').should == true
      drop_database @name
    end
  end

  it "should respond to update_user()" do
    @mysql.should respond_to(:update_user)
  end

  describe "update_user" do
    it "should return false when non existing user given" do
      @mysql.update_user('nonexistng', 'localhost', {}).should == false
    end

    it "should return false when malformed user given" do
      @mysql.update_user('root"', 'localhost', {}).should == false
    end

    it "should return false when non existing host given" do
      @mysql.update_user('root', 'nonexisting', {}).should == false
    end

    it "should return false when malformed host given" do
      @mysql.update_user('root', 'localhost"', {}).should == false
    end

    it "should return false when no password attribute given" do
      @mysql.update_user('root', 'localhost', {}).should == false
    end
  end

  describe "update_user" do
    before(:all) do
      @username = create_random_user('localhost')
      @old_password = get_user_password(@username, 'localhost')
      @response = @mysql.update_user(@username, 'localhost', :password => 'thenewpassword')
    end

    after(:all) do
      drop_user @username, 'localhost'
    end

    it "should return true" do
      @response.should == true
    end

    it "should change user password" do
      get_user_password(@username, 'localhost').should_not == @old_password
    end
  end

  it "should respond to destroy_user" do
    @mysql.should respond_to(:destroy_user)
  end

  describe "destroy_user" do
    it "should return false when nonexisting user name specified" do
      @mysql.destroy_user('nonexisting', 'localhost').should == false
    end

    it "should return false when malformed user name specified" do
      @mysql.destroy_user('nonexisting"', 'localhost').should == false
    end

    it "should return false when nonexisting host specified" do
      @mysql.destroy_user('root', 'nonexisting').should == false
    end

    it "should return true when existng user name and host specified" do
      @name = create_random_user
      @mysql.destroy_user(@name, 'localhost').should == true
    end
  end

  it "should respond to destroy_database" do
    @mysql.should respond_to(:destroy_database)
  end

  describe "destroy_database" do
    it "should return false when nonexisting database name specified" do
      @mysql.destroy_database('nonexisting_db').should == false
    end

    it "should return false when malformed database name specified" do
      @mysql.destroy_database('test"').should == false
    end

    it "should return true when existing database name specified" do
      @name = create_random_database
      @mysql.destroy_database(@name).should == true
    end
  end

  it "should respond to get_all_databases" do
    @mysql.should respond_to(:get_all_databases)
  end

  describe "get_all_databases" do
    it "should return an array" do
      @mysql.get_all_databases.should be_kind_of(Array)
    end

    it "should return an array of strings" do
      @mysql.get_all_databases.each do |database|
        database.should be_kind_of(String)
      end
    end
  end

  it "should respond to user_exists?" do
    @mysql.should respond_to(:user_exists?)
  end

  describe "user_exists?" do
    it "should return false when user doesn't exist" do
      @mysql.user_exists?('nonexistent_cz').should == false
    end

    it "should return false when user with host doesn't exist" do
      @mysql.user_exists?('nonexistent_cz', 'nonexistent').should == false
    end

    it "should return false when user exists but specified host not" do
      @mysql.user_exists?('root', 'nonexistent').should == false
    end

    it "should return true when user exists" do
      @mysql.user_exists?('root').should == true
    end

    it "should return true when user with host exists" do
      @mysql.user_exists?('root', 'localhost').should == true
    end
  end  

  it "should respond to database_exists?" do
    @mysql.should respond_to(:database_exists?)
  end

  describe "database_exists?" do
    it "should return false when user doesn't exist" do
      @mysql.database_exists?('nonexistent_cz').should == false
    end

    it "should return false when user with host doesn't exist" do
      @mysql.database_exists?('nonexistent_cz').should == false
    end

    it "should return true when domain exists" do
      @mysql.database_exists?('mysql').should == true
    end
  end

end