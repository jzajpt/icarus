#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../models/powerdns/domain')
require File.expand_path(File.dirname(__FILE__) + '/../models/powerdns/record')
require File.expand_path(File.dirname(__FILE__) + '/base')

module Backends
  class PowerDns
    backend_module

    SOA_CONTENT = 'ns1.blueberry.cz admin@blueberry.cz 1'

    # Creates domain record only, nothing else.
    def create_domain(name)
      domain = ::PowerDns::Domain.create(name)
      !domain.nil?
    end

    # Creates domain record and SOA record for it.
    def create_domain_with_soa_record(name)
      domain = ::PowerDns::Domain.create(name)
      return false if domain.nil?

      soa_record = ::PowerDns::Record.create :domain_id => domain.id, :name => name,
        :type => 'SOA', :content => SOA_CONTENT, :ttl => 600
      !soa_record.nil?
    end

    # Creates record with given attributes for given domain.
    def create_record(domain, name, type, content, ttl)
      domain = ::PowerDns::Domain.find_by_name(domain)
      return false if domain.nil?

      record = ::PowerDns::Record.create :domain_id => domain.id, :name => name, 
        :type => type, :content => content, :ttl => ttl
      !record.nil?
    end

    # Updates record found by name and type with given attributes. Returns true
    # if record was successfully updated.
    def update_record(record, type, attributes)
       record = ::PowerDns::Record.find_by_name_and_type record, type
       return false if record.nil?
       !!record.update(attributes)
    end

    # Deletes given record and returns true if everything went fine.
    def destroy_record(record, type)
      record = ::PowerDns::Record.find_by_name_and_type(record, type)
      return false if record.nil?
      !!record.destroy
    end

    # Deletes given domain and all associated records, returns true if everything went fine.
    def destroy_domain(domain)
      domain = ::PowerDns::Domain.find_by_name(domain)
      return false if domain.nil?
      !!domain.destroy
    end

    # Returns true if domain with given name exists.
    def domain_exists?(domain)
      domain = ::PowerDns::Domain.find_by_name(domain)
      !domain.nil?
    end

    # Returns true if record with given name and type exists.
    def record_exists?(record, type)
      record = ::PowerDns::Record.find_by_name_and_type(record, type)
      !record.nil?
    end

  end
end