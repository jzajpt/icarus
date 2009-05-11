require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Proftpd::FtpAccount finder", :shared => true do
  it "should return Proftpd::FtpAccount instance" do
    @ftp_account.should be_kind_of(Proftpd::FtpAccount)
  end

  %w(id username password uid gid ftpdir homedir valid_until).each do |attribute|
    it "should set #{attribute} attribute as string" do
      @ftp_account.send(attribute).should be_kind_of(String)
    end
  end
end

describe Proftpd::FtpAccount do
  before(:all) do
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/proftpd.sql'))
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/proftpd_test_data.sql'))
  end

  it "should have table_name class variable" do
    Proftpd::FtpAccount.table_name.should_not be_nil
  end

  describe "attributes" do
    before(:all) do
      @ftp_account = Proftpd::FtpAccount.new
    end

    %w(id username password uid gid ftpdir homedir valid_until).each do |attr|
      it "should have #{attr} getter" do
        @ftp_account.should respond_to(attr)
      end

      it "should have #{attr} setter" do
        @ftp_account.should respond_to("#{attr}=")
      end
    end
  end

  it "should respond to create" do
    Proftpd::FtpAccount.should respond_to(:create)
  end

  describe "create with invalid attributes" do
    it "should return nil when not attributes given" do
      Proftpd::FtpAccount.create({}).should == nil
    end
  end

  describe "create with valid attributes" do
    before(:all) do
      @attributes = {:username => 'johhnyquid', :password => 'password123', :domain => 'johnnyquid.cz', :subdomain => 'www'}
      @ftp_account = Proftpd::FtpAccount.create(@attributes)
    end

    # it_should_behave_like "Proftpd::FtpAccount finder"

    it "should create SQL record" do
      @sql_record = MysqlAdapter.select_one "SELECT * FROM #{Proftpd::FtpAccount.table_name} WHERE id = #{@ftp_account.id}"
      @sql_record.should be_kind_of(Hash)

      # Multiple expections in one examples suck, but i'm just way too lazy to break this down
      @sql_record['username'].should == @attributes[:username]
      @sql_record['password'].should == "{sha1}#{[Digest::SHA1.digest(@attributes[:password])].pack('m').strip}"
      @sql_record['ftpdir'].should == "/home/hosting/johnnyquid.cz/web/www"
      @sql_record['homedir'].should == "/home/hosting/johnnyquid.cz/web/www"
    end

  end

  it "should respond to find_by_username" do
    Proftpd::FtpAccount.should respond_to(:find_by_username)
  end

  describe "find_by_username with invalid attributes" do
    it "should return nil when invalid username was specified" do
      Proftpd::FtpAccount.find_by_username('nonexistent_username').should == nil
    end

    it "should return nil when malformed username was specified" do
      Proftpd::FtpAccount.find_by_username('nonexistent_username"').should == nil
    end
  end

  describe "find_by_username with valid attributes" do
    before(:all) do
      @ftp_account = Proftpd::FtpAccount.find_by_username('blueberry.cz')
    end

    it_should_behave_like "Proftpd::FtpAccount finder"

    it "should return Proftpd::FtpAccount instance" do
      @ftp_account.should be_kind_of(Proftpd::FtpAccount)
    end

    it "should set id attribute" do
      @ftp_account.id.should == '1'
    end

    it "should set username attribute" do
      @ftp_account.username.should == 'blueberry.cz'
    end
  end

end