require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Postfix::Mailbox finder", :shared => true do
  it "should return Postfix::Mailbox instance" do
    @mailbox.should be_kind_of(Postfix::Mailbox)
  end

  %w(id name username password domain maildir homedir quota).each do |attribute|
    it "should set #{attribute} attribute as string" do
      @mailbox.send(attribute).should be_kind_of(String)
    end
  end
end

describe Postfix::Mailbox do
  before(:all) do
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/postfix.sql'))
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/postfix_test_data.sql'))
  end

  it "should have table_name class variable" do
    Postfix::Mailbox.table_name.should_not be_nil
  end

  describe "attributes" do
    before(:all) do
      @mailbox = Postfix::Mailbox.new
    end

    %w(id name username domain password maildir homedir quota).each do |attr|
      it "should have #{attr} getter" do
        @mailbox.should respond_to(attr)
      end

      it "should have #{attr} setter" do
        @mailbox.should respond_to("#{attr}=")
      end
    end
  end

  it "create should return nil when username already exists" do
    Postfix::Mailbox.create('jzajpt@blueberry.cz', 'password123', 1024).should be_nil
  end

  it "create should return nil when given domain doesn't exist" do
    Postfix::Mailbox.create('jzajpt@nonexistent.cz', 'password123', 1024).should be_nil
  end

  it "find_by_username should return nil when username was not found" do
    Postfix::Mailbox.find_by_username('some@nonexistent.cz').should be_nil
  end

  it "find_by_username should return nil when malformed name specified" do
    Postfix::Mailbox.find_by_username("some@nonexistent\'.cz").should be_nil
  end

  it "find_by_id should return nil when domain was not found" do
    Postfix::Mailbox.find_by_id(9999).should be_nil
  end

  it "find_by_id should return nil even when malformed name specified" do
    Postfix::Mailbox.find_by_id('test').should be_nil
  end

  describe "create" do
    before(:all) do
      @domain = 'blueberry.cz'
      @user = "test#{rand(10000)}"
      @username = "#{@user}@#{@domain}"

      # Watch out for this, this is only stubbing here
      # Postfix::Alias.should_receive(:create).with(@username, @username).and_return(true)

      path = File.join(IcarusConfig[:postfix][:prefix], "#{@domain}/#{@user}/")
      FileUtils.should_receive(:chmod_R).with(0750, path).once.and_return(true)
      FileUtils.should_receive(:chown_R).once.and_return(true)

      @mailbox = Postfix::Mailbox.create(@username, 'password123', 1024*1024, 'Test User')
    end

    it_should_behave_like "Postfix::Mailbox finder"

    it "should set username attribute on instance" do
      @mailbox.username.should == @username
    end

    it "should set domain attribute on instance" do
      @mailbox.domain.should == @domain
    end

    it "should create mailbox SQL record" do
      @sql_record = MysqlAdapter.select_one "SELECT * FROM postfix_mailbox WHERE id = '#{@mailbox.id}'"
      @sql_record.should be_kind_of(Hash)

      # Multiple expectations in one example suck, but i'm just too lazy to break this down
      @sql_record['username'].should == @username
      @sql_record['domain'].should == 'blueberry.cz'
      @sql_record['password'].should == Base64.encode64(Digest::SHA2.digest('password123')).strip
      @sql_record['quota'].should == (1024*1024).to_s
      @sql_record['quota'].should == (1024*1024).to_s
      @sql_record['homedir'].should == IcarusConfig[:postfix][:prefix]
      @sql_record['maildir'].should == "#{@domain}/#{@user}/"
    end

    it "should create alias SQL record" do
      @sql_record = MysqlAdapter.select_one "SELECT * FROM postfix_alias WHERE address = '#{@username}' and goto = '#{@username}'"
      @sql_record.should be_kind_of(Hash)
    end
  end

  describe "find_by_name" do  
    before(:all) do
      @username = 'jzajpt@blueberry.cz'
      @mailbox = Postfix::Mailbox.find_by_username('jzajpt@blueberry.cz')
    end

    it_should_behave_like "Postfix::Mailbox finder"

    it "should set username attribute" do
      @mailbox.username.should == 'jzajpt@blueberry.cz'
    end

    it "should set domain attribute" do
      @mailbox.domain.should == 'blueberry.cz'
    end
  end

  describe "find_by_id" do  
    before(:all) do
      @mailbox = Postfix::Mailbox.find_by_id(1)
    end

    it_should_behave_like "Postfix::Mailbox finder"
  end


  describe "update" do
    before(:all) do
      @mailbox = Postfix::Mailbox.find_by_id(1)      
    end

    it "should raise ArgumentError when invalid attributes given" do
      pending
      @mailbox.update(:invalidkey => 'value').should == false
    end

    it "should return true when empty attributes given" do
      pending
      @mailbox.update({}).should == true
    end

    it "should return true when valid attributes given" do
      pending
      @mailbox.update(:quota => 1024*1024).should == true
    end
  end

  describe "destroy" do
    before(:all) do
      @mailbox = Postfix::Mailbox.find_by_id(1)
      @result = @mailbox.destroy
    end

    it "should return true" do
      @result.should == true
    end

    it "should destroy mailbox" do
      Postfix::Mailbox.find_by_id(@mailbox.id).should be_nil
    end
  end

end