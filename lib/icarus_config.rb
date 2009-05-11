require File.expand_path(File.dirname(__FILE__) + '/ext/hash')

class IcarusConfig
  class << self
    attr_accessor :config_file
    attr_accessor :config

    attr_reader :listen_address
    attr_reader :listen_port

    def load(filename)
      @config = YAML.load_file(filename).deep_symbolize_keys

      check_icarus_config
      check_postfix_config
      check_proftpd_config    
    end

    def [](key)
      @config[key]
    end

    protected

    def check_icarus_config
      @config.assert_required_keys(:icarus)
      @config[:icarus].assert_required_keys(:listen_port, :listen_address, :security_token,
        :backends, :ssl_private_key, :ssl_certificate, :username, :password)
      @listen_address = @config[:icarus][:listen_address]
      @listen_port    = @config[:icarus][:listen_port]
    end

    def check_postfix_config
      if @config[:icarus][:backends].include?('postfix')
        @config.assert_required_keys(:postfix)
        @config[:postfix].assert_required_keys(:prefix, :maildirmake, :user, :group)
      end
    end

    def check_proftpd_config
      if @config[:icarus][:backends].include?('proftpd')
        @config.assert_required_keys(:proftpd)
        @config[:proftpd].assert_required_keys(:path)
      end
    end
  end
end