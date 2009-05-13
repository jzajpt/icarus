#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/base')

module Backends
  class Apache
    backend_module
    
    # Create new hosting domain. Involves creating dummy config for apache
    # and adding system user. 
    #
    # === Attributes
    #
    # * <tt>:can_login</tt> 
    def create_domain(name, attributes)
      shell = attributes[:can_login] ? '/bin/bash' : '/sbin/nologin'
      home_directory = "#{IcarusConfig[:apache][:prefix]}/#{name}"
      description = "#{domain} hosting account"
      username = System::User.normalize_username(domain)

      if System::User.create(username, :home => home_directory, 
        :shell => shell, :description => description, :create_home => true)
        # ok
      else
        # false
      end
    end
    
    def destroy_domain(name)
      
    end
    
    def domain_exists?(name)
      
    end

    def create_subdomain(name, attributes)
      subdomain_directory = get_subdomain_directory(name)
      document_root = "#{subdomain_directory}/htdocs"
      error_log = "#{subdomain_directory}/logs/error.log"

      Apache::VirtualHost.create(
        :server_name => name,
        :access_log => :rotate_daily,
        :log_dir => "#{subdomain_directory}/logs",
        :error_log => error_log)
    end

    def update_subdomain(name, attributes)
      # Apache::VirtualHost.find_by_server_name(name)
    end

    def destroy_subdomain(name)
      
    end

    def subdomain_exists?(name, look_also_for_alias = true)
      # Apache::VirtualHost.find_by_server_name(name)
    end

    protected
    
    def extract_subdomain(name)
      subdomain, *domain = name.split('.')
      [subdomain, domain.join('.')]
    end
    
    def get_subdomain_directory(name)
      subdomain, domain = extract_subdomain(name)
      "#{IcarusConfig[:apache][:prefix]}/#{domain}/#{subdomain}"
    end
  end
end