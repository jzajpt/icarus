#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../../stupid_record/record')
require File.expand_path(File.dirname(__FILE__) + '/../../ext/hash')
require File.expand_path(File.dirname(__FILE__) + '/domain')


module PowerDns
  class Record < StupidRecord::Record
    self.table_name = 'records'

    attribute :name
    attribute :type
    attribute :content
    attribute :domain_id
    attribute :ttl
    attribute :prio

    # Open up singleton
    class << self
      # Creates new record with given attributes and returns Record instance.
      # def create(domain_id, name, type, content, ttl, prio = nil)
      def create(attributes = {})
        attributes.symbolize_keys!
        return nil unless attributes.has_keys?(:domain_id, :name, :type, :content, :ttl)

        # Check if we have valid domain_id given
        domain = Domain.find_by_id(attributes[:domain_id])
        return nil if domain.nil?

        # Check for duplicate record
        record = Record.find_by_name_and_type_and_content(attributes[:name], 
          attributes[:type], attributes[:content])
        return nil if record

        attributes[:id] = MysqlAdapter.insert(construct_sql_insert(attributes))

        new(attributes)
      rescue Mysql::Error
        nil
      end

      # Finds record by given name and type, returns Record instance or nil.
      def find_by_name_and_type(name, type)
        record = finder(:select => [:id, :domain_id, :name, :type, :content, :ttl],
                        :conditions => {:name => name, :type => type})
        return nil if record.nil?

        new(record)
      end

      # Finds record by given name, type and content. Returns Record instance or nil.
      def find_by_name_and_type_and_content(name, type, content)
        record = finder(:select => [:id, :domain_id, :name, :type, :content, :ttl],
                        :conditions => {:name => name, :type => type, :content => content})
        return nil if record.nil?

        new(record)
      end
    end

    # Returns Domain instance underwhich record belongs.
    def domain
      Domain.find_by_id(domain_id)
    end
  end
end