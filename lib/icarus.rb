require File.expand_path(File.dirname(__FILE__) + '/icarus_config')
require File.expand_path(File.dirname(__FILE__) + '/ext/icarus_servlet')


class Icarus
  VERSION = '1.0.0'

  def initialize(config_file = nil)
    IcarusConfig.load(config_file ||
      File.expand_path(File.dirname(__FILE__) + '/../config/config.yml'))
    setup_servlet
    load_ssl_certificates
    setup_webrick
  end

  protected

  # Setups XMLRPC servlet for Webrick
  def setup_servlet
    @xmlrpc_servlet = IcarusServlet.new
    @xmlrpc_servlet.username = IcarusConfig[:icarus][:username]
    @xmlrpc_servlet.password = IcarusConfig[:icarus][:password]

    if IcarusConfig[:icarus][:backends].include?('system')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('system'), Backends::System.new)  
    end

    if IcarusConfig[:icarus][:backends].include?('powerdns')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('powerdns'), Backends::PowerDns.new)  
    end

    if IcarusConfig[:icarus][:backends].include?('postfix')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('postfix'), Backends::Postfix.new)  
    end

    if IcarusConfig[:icarus][:backends].include?('proftpd')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('proftpd'), Backends::Proftpd.new)  
    end

    if IcarusConfig[:icarus][:backends].include?('mysql')
      @xmlrpc_servlet.add_handler(XMLRPC::iPIMethods('mysql'), Backends::Mysql.new)  
    end

    # Add Icarus version handler
    @xmlrpc_servlet.add_handler('icarus.version') do
      VERSION
    end
  end

  # Loads necessary SSL certficates.
  def load_ssl_certificates
    private_key_file = File.expand_path(File.dirname('/../config') +
      IcarusConfig[:icarus][:ssl_private_key])
    certificate_file = File.expand_path(File.dirname('/../config') +
      IcarusConfig[:icarus][:ssl_certificate])
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