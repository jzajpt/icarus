#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

module Apache
  
  # Class represeting Apache virtual host.
  class VirtualHost
    class ConfigFileError < StandardError; end

    attr_accessor :config

    attr_accessor :server_name
    attr_accessor :server_aliases
    attr_accessor :document_root
    attr_accessor :error_pages
    attr_accessor :error_log
    attr_accessor :access_log
    attr_accessor :php_safe_mode
    attr_accessor :user_id

    class << self
      # Create new Apache virtual host based on given attributes.
      #
      # === Required attributes
      #
      # * <tt>:server_name</tt> 
      # * <tt>:document_root</tt>
      # * <tt>:access_log</tt> - path to access log or :rotate_daily.
      # * <tt>:error_log</tt>
      #
      # === Optional attributes
      #
      # * <tt>:server_aliases</tt>
      # * <tt>:php_safe_mode</tt> 
      # * <tt>:php_open_basedir</tt> 
      # * <tt>:error_pages</tt>
      # * <tt>:log_dir</tt> - required when :access_log is set to :rotate_daily
      def create(attributes)
        attributes.assert_required_keys(:server_name, :document_root, :access_log, :error_log)
        attributes[:assign_user_id] = get_user_id(attributes[:server_name]) if IcarusConfig[:apache][:use_mod_itk]

        instance = new
        %w(server_name server_aliases document_root error_log access_log
          php_safe_mode error_pages).each do |attr|
          instance.send(:"#{attr}=", attributes[attr.to_sym])
        end

        if attributes[:access_log] == :rotate_daily
          attributes.assert_required_keys(:log_dir)
          attributes[:access_log] = get_log_rotation_string(attributes[:log_dir])
        end
        instance.config = render_config(binding)
        instance
      end
      
      def find_by_server_name(server_name)

      end
      
      protected
      
      # Return rendered configuration file for Apache virtual host.
      def render_config(binding)
        ERB.new(IO.read(File.expand_path(File.dirname(__FILE__) +
          '/../../../config/virtual_host_template.conf.erb'))).result(binding)
      end

      # Returns system user to run under for mod_itk.
      def get_user_id(name)
        System::User.normalize_username(name)
      end
      
      def get_log_rotation_string(dir)
        %Q{"|/usr/sbin/rotatelogs -l #{dir}/access.%Y%m%d.log 86400" combined"}
      end
    end

    def initialize(config_file = nil)
      @config = Apache::Config.new(config_file) if config_file
      process_config if config_file
    rescue Errno::ENOENT
      raise ArgumentError.new('Invalid config file given')
    end

    # Write Apache configuration file for virtualhost into given file.
    def write(file_name)
      File.open(file_name, "w") { |file| file.write(config.dump) }
    end

    protected

    def process_config
      @server_name = get_directive_value('ServerName')
      if aliases_directive = get_section.find_directive_by_name('ServerAlias')
        @server_aliases = aliases_directive.value.split(' ')
      end
      @document_root = get_directive_value('DocumentRoot')
      @error_log = get_directive_value('ErrorLog')
      @access_log = get_directive_value('CustomLog')
      @php_safe_mode = get_php_admin_flag_value('safe_mode')
    end

    def get_section
      @virtual_host_section ||= @config.find_section_by_name('VirtualHost')
      raise ConfigFileError unless @virtual_host_section
      @virtual_host_section
    end

    def get_directive_value(directive)
      get_section.find_directive_by_name(directive).value
    end

    def get_php_admin_flag_value(flag)
      directives = get_section.find_directives_by_name('php_admin_flag')
      directives.each do |directive|
        tokens = directive.value.split(' ')
        if tokens.first == flag
          return tokens.last.downcase == 'on' ? true : false
        end
      end
      nil
    end

    def get_php_admin_value(name)
      directives = get_section.find_directives_by_name('php_admin_value')
      directives.each do |directive|
        tokens = directive.value.split(' ')
        return tokens.join(' ') if tokens.shift == name
      end
      nil
    end
  end
end