require 'xmlrpc/server'
require 'logger'
require 'openssl'
require 'webrick'
require 'webrick/https'

require File.expand_path(File.dirname(__FILE__) + '/icarus_config')
require File.expand_path(File.dirname(__FILE__) + '/ext/icarus_servlet')
require File.expand_path(File.dirname(__FILE__) + '/adapters/mysql_adapter')

class Icarus
  VERSION = '1.0.0'

  def initialize(config_file = nil)
    IcarusConfig.load(config_file ||
      File.expand_path(File.dirname(__FILE__) + '/../config/config.yml'))
    setup_servlet
    setup_mysql_connection
    load_icarus_modules
    load_ssl_certificates
    setup_webrick
  end
  
  # Starts Webrick server
  def start
    @server.start
  end
  
  # Stops Webrick server
  def stop
    @server.shutdown
  end

  protected
  
  def setup_mysql_connection
    MysqlAdapter.connect(IcarusConfig[:mysql_adapter])
  end

  # Setups XMLRPC servlet for Webrick
  def setup_servlet
    @xmlrpc_servlet = IcarusServlet.new
    @xmlrpc_servlet.username = IcarusConfig[:icarus][:username]
    @xmlrpc_servlet.password = IcarusConfig[:icarus][:password]
    
    # Add Icarus version handler
    @xmlrpc_servlet.add_handler('icarus.version') do
      VERSION
    end
  end
  
  # Loads all necessary Icarus modules
  def load_icarus_modules
    if IcarusConfig[:icarus][:backends].include?('apache')
      require File.expand_path(File.dirname(__FILE__) + '/backends/apache')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('apache'), Backends::Apache.new)  
    end
    
    if IcarusConfig[:icarus][:backends].include?('mysql')
      require File.expand_path(File.dirname(__FILE__) + '/backends/mysql')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('mysql'), Backends::Mysql.new)  
    end

    if IcarusConfig[:icarus][:backends].include?('system')
      require File.expand_path(File.dirname(__FILE__) + '/backends/system')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('system'), Backends::System.new)  
    end

    if IcarusConfig[:icarus][:backends].include?('powerdns')
      require File.expand_path(File.dirname(__FILE__) + '/backends/powerdns')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('powerdns'), Backends::PowerDns.new)  
    end

    if IcarusConfig[:icarus][:backends].include?('postfix')
      require File.expand_path(File.dirname(__FILE__) + '/backends/postfix')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('postfix'), Backends::Postfix.new)  
    end

    if IcarusConfig[:icarus][:backends].include?('proftpd')
      require File.expand_path(File.dirname(__FILE__) + '/backends/proftpd')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('proftpd'), Backends::Proftpd.new)  
    end
  end

  # Loads necessary SSL certficates.
  def load_ssl_certificates
    private_key_file = File.expand_path(File.dirname(__FILE__) + '/../config/' + IcarusConfig[:icarus][:ssl_private_key])
    certificate_file = File.expand_path(File.dirname(__FILE__) + '/../config/' + IcarusConfig[:icarus][:ssl_certificate])
    @ssl_private_key = OpenSSL::PKey::RSA.new(File.open(private_key_file).read)
    @ssl_certificate = OpenSSL::X509::Certificate.new(File.open(certificate_file).read)
  end

  # Setups Webrick HTTP server and mounts XMLRPC servlet to it
  def setup_webrick
    logger = Logger.new(File.expand_path(File.dirname(__FILE__) + '/../log/webrick-server.log'))
    logger.level = Logger::WARN

    access_log_stream = File.open('webrick-access.log', 'w')
    access_log = [[access_log_stream, WEBrick::AccessLog::COMBINED_LOG_FORMAT]]

    # Setup Webrick's HTTP server
    @server = WEBrick::HTTPServer.new(
      :Port            => IcarusConfig[:icarus][:listen_port],
      :BindAddress     => IcarusConfig[:icarus][:listen_address],
      :MaxClients      => 10,
      :Logger          => logger,
      :AccessLog       => access_log,
      :SSLEnable       => true,
      :SSLVerifyClient => ::OpenSSL::SSL::VERIFY_NONE,
      :SSLCertificate  => @ssl_certificate,
      :SSLPrivateKey   => @ssl_private_key
    )

    # Mount servlet with Icarus
    @server.mount("/icarus/#{IcarusConfig[:icarus][:security_token]}", @xmlrpc_servlet)
  end
end