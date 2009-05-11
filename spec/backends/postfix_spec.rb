require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Backends::Postfix do
  before(:all) do
    process_sql_file(File.join(File.dirname(__FILE__), '/../../sql/postfix.sql'))
    process_sql_file(File.join(File.dirname(__FILE__), '/../../sql/postfix_test_data.sql'))

    @postfix = Backends::Postfix.new
  end

  it "should respond to present?" do
    @postfix.present?.should == true
  end

  it "should respond to name" do
    @postfix.name.should == 'Backends::Postfix'
  end

  it "should respond to create_domain" do
    @postfix.should respond_to(:create_domain)
  end

  describe "create_domain" do
    it "should return false if domain already exists" do
      @postfix.create_domain('blueberry.cz').should == false
    end

    it "should return true when domain was created" do
      name = "test#{rand(10000)}.cz"
      @postfix.create_domain(name).should == true
      @postfix.domain_exists?(name).should == true
    end
  end

  it "should respond to create_mailbox" do
    @postfix.should respond_to(:create_mailbox)
  end

  describe "create_mailbox" do
    it "should return false if mailbox already exists" do
      @postfix.create_mailbox('jzajpt@blueberry.cz', 'password123', 1024*1024).should == false
    end

    it "should return false if domain already exists" do
      @postfix.create_mailbox('johnny@nonexistent.cz', 'password123', 1024*1024).should == false
    end

    it "should return true when mailbox was created" do
      username = "test#{rand(10000)}@blueberry.cz"
      @postfix.create_mailbox(username, 'password123', 1024*1024).should == true
      @postfix.mailbox_exists?(username).should == true
    end
  end

  it "should respond to create_alias" do
    @postfix.should respond_to(:create_alias)
  end

  describe "create_alias" do
    it "should return false if alias already exists" do
      @postfix.create_alias('jzajpt@blueberry.cz', 'jzajpt@blueberry.cz').should == false
    end

    it "should return false if domain already exists" do
      @postfix.create_alias('johnny@nonexistent.cz', 'johnny@else.com').should == false
    end

    it "should return true when mailbox was created" do
      @postfix.create_alias('jirka@blueberry.cz', 'jzajpt@blueberry.cz').should == true
      @postfix.alias_exists?('jirka@blueberry.cz').should == true
    end
  end

  it "should respond to create_alias" do
    @postfix.should respond_to(:create_alias)
  end

  describe "create_alias" do
    it "should return false if alias already exists" do
      @postfix.create_alias('jzajpt@blueberry.cz', 'jzajpt@blueberry.cz').should == false
    end

    it "should return false if domain already exists" do
      @postfix.create_alias('johnny@nonexistent.cz', 'johnny@else.com').should == false
    end

    it "should return true when mailbox was created" do
      @postfix.create_alias('jirka@blueberry.cz', 'jzajpt@blueberry.cz').should == true
      @postfix.alias_exists?('jirka@blueberry.cz').should == true
    end
  end

  it "should respond to destroy_domain" do
    @postfix.should respond_to(:destroy_domain)
  end

  describe "successfull destroy_domain" do
    before(:each) do
      @response = @postfix.destroy_domain('blueberry.cz')
    end

    it "should return true when successful" do
     @response.should == true
    end

    it "should destroy domain" do
      @postfix.domain_exists?('blueberry.cz').should == false
    end

    it "should all domain mailboxes" do
      @postfix.mailbox_exists?('jzajpt@blueberry.cz').should == false
    end

    it "should all domain aliases" do
      @postfix.alias_exists?('jzajpt@blueberry.cz').should == false
    end
  end

  it "should respond to destroy_mailbox" do
    @postfix.should respond_to(:destroy_mailbox)
  end  

  it "destroy_mailbox should return false if mailbox doesn't exist" do
    @postfix.destroy_mailbox('johnny@nonexistent.cz').should == false
  end

  describe "successfull destroy_mailbox" do
    before(:each) do
      @response = @postfix.destroy_mailbox('jzajpt@blueberry.cz')
    end

    it "should return true when successful" do
      @response.should == true
    end

    it "should not destroy domain" do
      @postfix.domain_exists?('blueberry.cz').should == true
    end

    it "should destroy mailbox" do
      @postfix.mailbox_exists?('jzajpt@blueberry.cz').should == false
    end
  end

  it "should respond to destroy_alias" do
    @postfix.should respond_to(:destroy_alias)
  end

  it "destroy_alias should return false if address doesn't exist" do
    @postfix.destroy_alias('johnny@nonexistent.cz', 'johnny@else.com').should == false
  end

  it "destroy_alias should return false if goto doesn't exist" do
    @postfix.destroy_alias('jzajpt@blueberry.cz', 'johnny@else.com').should == false
  end

  describe "successfull destroy_alias" do
    before(:each) do
      @response = @postfix.destroy_alias('jzajpt@blueberry.cz', 'jzajpt@blueberry.cz')
    end

    it "should return true" do
      @response.should == true
    end

    it "should not destroy domain" do
      @postfix.domain_exists?('blueberry.cz').should == true
    end

    it "should not destroy mailbox" do
      @postfix.mailbox_exists?('jzajpt@blueberry.cz').should == true
    end

    it "should destroy mailbox" do
      @postfix.alias_exists?('jzajpt@blueberry.cz').should == false
    end
  end

  it "should respond to domain_exists?" do
    @postfix.should respond_to(:domain_exists?)
  end

  describe "domain_exists?" do
    it "should return false when domain doesn't exist" do
      @postfix.domain_exists?('nonexistent.cz').should == false
    end

    it "should return true when domain exists" do
      @postfix.domain_exists?('blueberry.cz').should == true
    end
  end

  it "should respond to mailbox_exists?" do
    @postfix.should respond_to(:mailbox_exists?)
  end

  describe "mailbox_exists?" do
    it "should return false when mailbox doesn't exist" do
      @postfix.mailbox_exists?('jzajpt@nonexistent.cz').should == false
    end

    it "should return false when user doesn't exist" do
      @postfix.mailbox_exists?('nonexistent@blueberry.cz').should == false
    end

    it "should return true when mailbox exists" do
      @postfix.mailbox_exists?('jzajpt@blueberry.cz').should == true
    end
  end

  it "should respond to alias_exists?" do
    @postfix.should respond_to(:alias_exists?)
  end

  describe "alias_exists?" do
    it "should return false when alias doesn't exist" do
      @postfix.alias_exists?('jzajpt@nonexistent.cz').should == false
    end

    it "should return false when address doesn't exist" do
      @postfix.alias_exists?('nonexistent@blueberry.cz').should == false
    end

    it "should return false when goto doesn't exist" do
      @postfix.alias_exists?('jzajpt@blueberry.cz', 'nonexistent@alias.com').should == false
    end

    it "should return true when address exists" do
      @postfix.alias_exists?('jzajpt@blueberry.cz').should == true
    end

    it "should return true when address and goto exists" do
      @postfix.alias_exists?('jzajpt@blueberry.cz', 'jzajpt@blueberry.cz').should == true
    end
  end
end