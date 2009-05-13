$: << File.join(File.dirname(__FILE__), "/../lib") 
require 'spec'
require 'erb'

require File.expand_path(File.dirname(__FILE__) + '/helpers/sql_helper')
require File.expand_path(File.dirname(__FILE__) + '/helpers/mysql_helper')

require 'ext/hash'
require 'adapters/mysql_adapter'
require 'stupid_record/record'
require 'icarus_config'
require 'models/system/user'
require 'models/apache/directive'
require 'models/apache/section'
require 'models/apache/config'
require 'models/apache/virtual_host'
require 'models/proftpd/ftp_account'
require 'models/postfix/domain'
require 'models/postfix/alias'
require 'models/postfix/mailbox'
require 'models/powerdns/domain'
require 'models/powerdns/record'
require 'models/mysql/database'
require 'models/mysql/user'
require 'backends/apache'
require 'backends/base'
require 'backends/mysql'
require 'backends/postfix'
require 'backends/powerdns'
require 'backends/proftpd'
require 'backends/system'


Spec::Runner.configure do |config|
  config.include SqlHelper

  config.before(:all) do
    setup_mysql_connection
    load_test_configuration
  end
  
  config.after(:all) do
    File.delete @icarus_config_file if File.exists? @icarus_config_file
  end

  def setup_mysql_connection
    # Specify valid credentials for test database!
    database_configuration = {
      :host => 'localhost',
      :user => 'root',
      :password => '',
      :database => 'icarus_test'
    }
    MysqlAdapter.connect(database_configuration)
    puts "Can't connect to database" and exit unless MysqlAdapter.connected?
  end
  
  def load_test_configuration
    config_file_template = File.expand_path(File.dirname(__FILE__) + '/../test/config.yml.erb')
    @icarus_config_file = File.expand_path(File.dirname(__FILE__) + '/../test/config.yml')
    
    test_prefix      = '/tmp'
    test_maildirmake = 'true'
    test_user        = ENV['USER']
    test_group       = ENV['GROUP']

    content = ERB.new(IO.read(config_file_template)).result(binding)
    File.open(@icarus_config_file, "w") { |f| f.puts content }
    
    IcarusConfig.load(@icarus_config_file)
  end
end
