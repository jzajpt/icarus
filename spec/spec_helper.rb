$: << File.join(File.dirname(__FILE__), "/../lib") 
require 'spec'
require 'erb'

require File.expand_path(File.dirname(__FILE__) + '/helpers/sql_helper')
require File.expand_path(File.dirname(__FILE__) + '/helpers/mysql_helper')

require 'ext/hash'
require 'adapters/mysql_adapter'
require 'stupid_record/record'
require 'icarus_config'
require 'models/proftpd/ftp_account'
require 'models/postfix/domain'
require 'models/postfix/alias'
require 'models/postfix/mailbox'
require 'models/powerdns/domain'
require 'models/powerdns/record'
require 'models/mysql/database'
require 'models/mysql/user'
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
    File.delete @config_file if File.exists? @config_file
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
    @config_file = File.expand_path(File.dirname(__FILE__) + '/../test/config.yml')
    
    test_prefix      = '/tmp'
    test_maildirmake = 'true'
    test_user        = ENV['USER']
    test_group       = ENV['GROUP']

    content = ERB.new(IO.read(config_file_template)).result(binding)
    File.open(@config_file, "w") { |f| f.puts content }
    
    IcarusConfig.load(@config_file)
  end
end
