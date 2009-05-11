#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../../stupid_record/record')
require File.expand_path(File.dirname(__FILE__) + '/domain')


module Postfix
  class Alias < StupidRecord::Record
    self.table_name = 'postfix_alias'

    attribute :address
    attribute :goto
    attribute :domain

    # Open up singleton
    class << self
      # Creates new alias with given address and goto and returns Alias instance.
      # Checks if domain in address exists, also checks for duplicate aliases.
      def create(address, goto)
        user, domain = address.split('@')

        # Check for postfix domain record
        domain_record = Domain.find_by_name(domain)
        return nil if domain_record.nil? 

        # Check for existing alias
        alias_record = Alias.find_by_address_and_goto(address, goto)
        return nil if alias_record

        id = MysqlAdapter.insert "INSERT INTO #{table_name}(address, goto, domain, created, modified) VALUES
                          ('#{address}', '#{goto}', '#{domain}', now(), now())"

        instance         = new
        instance.id      = id.to_s
        instance.address = address
        instance.goto    = goto
        instance.domain  = domain
        instance
      rescue Mysql::Error
        nil
      end

      # Finds alias with given address and returns Alias instance.
      def find_by_address(address)
        alias_record = finder(
          :select => [:id, :address, :goto, :domain],
          :conditions => {:address => address})
        return nil if alias_record.nil?

        new(alias_record)
      end

      # Finds alias with given address and goto destination, returns Alias instance.
      def find_by_address_and_goto(address, goto)
        alias_record = finder(
          :select => [:id, :address, :goto, :domain], 
          :conditions => {:address => address, :goto => goto})
        return nil if alias_record.nil?

        new(alias_record)
      end
    end

  end
end
