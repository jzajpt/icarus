#!/usr/bin/env ruby -wKU

class VerifyIcarus
  attr_accessor :address, :security_token, :username, :password

  class << self
    def usage
      puts "Usage: verify_icarus.rb <address> <token>"
      exit
    end
  end

  def initialize(params_or_nil = nil)
    if params_or_nil
      @address, @security_token = params_or_nil
    else
      file = File.join(File.dirname(__FILE__), "/config/config.yml")
      config = YAML.load_file(file).deep_symbolize_keys
      @address = "#{config[:icarus][:listen_address]}:#{config[:icarus][:listen_port]}"
      @security_token = config[:icarus][:security_token]
      @username = config[:icarus][:username]
      @password = config[:icarus][:password]
    end
  end

  def verify
    check_ssl(address)

    begin
      server = XMLRPC::Client.new_from_uri("https://#{address}/icarus/#{security_token}")
      server.user = username
      server.password = password

      puts "-- ICARUS INFO --------------------------------------"
      puts " - version:  #{server.call('icarus.version')}"
      puts "-- MODULES INFO -------------------------------------"
      puts "System module present: " + check_module(server, 'system').to_s
      puts " - uname:  #{server.call('system.uname')}"
      puts " - uptime: #{server.call('system.uptime')}"
      puts "PowerDNS module present: " + check_module(server, 'powerdns').to_s
      puts "Postfix module present: " + check_module(server, 'postfix').to_s
    rescue Errno::ECONNREFUSED
      puts "Server on #{address} isn't running! (Connection refused)"
    end
  end

  protected

  def check_ssl(address)
    require 'net/https'
    require 'uri'

    uri  = URI.parse("https://#{address}/")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    puts "-- HTTPS INFO ---------------------------------------"
    http.start {
      puts " - issuer: " + http.peer_cert.issuer.to_s
      puts " - signature algorithm: " + http.peer_cert.signature_algorithm.to_s
      puts " - subject: " + http.peer_cert.subject.to_s
    }
  end

  def check_module(server, name)
    begin
      server.call("#{name}.present?")
    rescue XMLRPC::FaultException
      false
    end
  end
end