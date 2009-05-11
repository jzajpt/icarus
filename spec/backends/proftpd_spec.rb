require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Backends::Proftpd do
  before(:all) do
    process_sql_file(File.join(File.dirname(__FILE__), '/../../sql/proftpd.sql'))
    process_sql_file(File.join(File.dirname(__FILE__), '/../../sql/proftpd_test_data.sql'))

    @proftpd = Backends::Proftpd.new
  end

  it "should respond to present?" do
    @proftpd.present?.should == true
  end

  it "should respond to name" do
    @proftpd.name.should == 'Backends::Proftpd'
  end

  it "should respond to create_ftp_account" do
    @proftpd.should respond_to(:create_ftp_account)
  end

  describe "create_ftp_account" do
    it "should return false when no attributes specified" do
      @proftpd.create_ftp_account({}).should == false
    end

    it "should return true when given valid attributes" do
      @attributes = {:username => 'johnnyquid.cz', :password => 'password123',
        :domain => 'johnnyquid.cz'}
      @proftpd.create_ftp_account(@attributes).should == true
    end
  end

  it "should respond to update_ftp_account" do
    @proftpd.should respond_to(:update_ftp_account)    
  end

  describe "update_ftp_account" do
    it "should return false when invalid username specified" do
      @proftpd.update_ftp_account('nonexistent', {}).should == false
    end

    it "should return false when valid username specified" do
      @proftpd.update_ftp_account('blueberry.cz', {}).should == false
    end

    it "should return false when invalid attributes specified" do
      @proftpd.update_ftp_account('blueberry.cz', {:invalid => 'value'}).should == false
    end

    it "should return true when valid username specified" do
      @proftpd.update_ftp_account('blueberry.cz', :password => 'papadap').should == true
    end
  end

  it "should respond to destroy_ftp_account" do
    @proftpd.should respond_to(:destroy_ftp_account)
  end

  describe "destroy_ftp_account" do
    it "should return false when ftp account doesn't exist" do
      @proftpd.destroy_ftp_account('nonexistent_account').should == false
    end

    it "should return false when ftp account malformed username was specified" do
      @proftpd.destroy_ftp_account('blueberry.cz\'').should == false
    end

    it "should return true and destroy record" do
      @proftpd.destroy_ftp_account('blueberry.cz').should == true
    end
  end

  it "should respond to ftp_account_exists?" do
    @proftpd.should respond_to(:ftp_account_exists?)
  end

  describe "ftp_account_exists" do
    it "should return false when ftp account doesn't exist" do
      @proftpd.ftp_account_exists?('nonexistent_account').should == false
    end

    it "should return false when ftp account malformed username was specified" do
      @proftpd.ftp_account_exists?('blueberry.cz\'').should == false
    end

    it "should return true when ftp account with given username exists" do
      @proftpd.ftp_account_exists?('blueberry.cz').should == true
    end
  end

end
