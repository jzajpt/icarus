require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Apache::VirtualHost do
  it "should raise ArgumentError when invalid filename given" do
    lambda { Apache::VirtualHost.new('nonexistent.conf') }.should raise_error(ArgumentError)
  end
  
  it "should raise ConfigFileError when config file without virtualhost section given" do
    config = File.expand_path(File.dirname(__FILE__) + '/../../../test/virtual_host_bad.conf')
    lambda { Apache::VirtualHost.new(config) }.should raise_error(Apache::VirtualHost::ConfigFileError)
  end

  context "initiated from config file" do
    before(:all) do
      # All these examples depends on content of virtual_host.conf file, so beware.
      @config_file = File.expand_path(File.dirname(__FILE__) + '/../../../test/virtual_host.conf')
      @virtual_host = Apache::VirtualHost.new(@config_file)
    end

    it "should return server name" do
      @virtual_host.server_name.should == 'www.demo.cz'
    end

    it "should return server aliases" do
      @virtual_host.server_aliases.should == ['demo.cz']
    end

    it "should return document root" do
      @virtual_host.document_root.should == '/home/hosting/demo.cz/web/www/htdocs'
    end

    it "should return error log" do
      @virtual_host.error_log.should == '/home/hosting/demo.cz/web/www/logs/error.log'
    end

    it "should return access log" do
      @virtual_host.access_log.should be_kind_of(String)
    end

    it "should return safe mode" do
      @virtual_host.php_safe_mode.should == true
    end
  end

  context "creating" do
    it "should raise ArgumentError when not all required keys were given" do
      lambda { Apache::VirtualHost.create(:server_name => 'www.test.cz') }.should
        raise_error(ArgumentError)
    end

    it "should return VirtualHost instance with attributes set" do
      @virtual_host = create_virtual_host
      puts @virtual_host.config
      @virtual_host.should be_kind_of(Apache::VirtualHost)
      @virtual_host.server_name.should == 'demo.cz'
      @virtual_host.document_root.should == '/var/www/demo.cz'
      @virtual_host.access_log.should == '/var/log/demo.cz-access-log'
      @virtual_host.error_log.should == '/var/log/demo.cz-error-log'
    end

    it "should create config file" do
      @virtual_host = create_virtual_host
      @virtual_host.config.should be_kind_of(String)
    end

    def create_virtual_host
      Apache::VirtualHost.create(:server_name => 'demo.cz',
        :document_root => '/var/www/demo.cz',
        :access_log => '/var/log/demo.cz-access-log',
        :error_log => '/var/log/demo.cz-error-log')
    end
  end
end
