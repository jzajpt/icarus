#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../../stupid_record/record')
require File.expand_path(File.dirname(__FILE__) + '/record')


module PowerDns
  class Domain < StupidRecord::Record
    self.table_name = 'domains'

    attribute :name
    attribute :type

    # Open up singleton
    class << self
      # Creates new domain record and returns Domain instance.
      def create(name)
        id = MysqlAdapter.insert "INSERT INTO #{table_name}(name) VALUES('#{name}')"
        instance      = new
        instance.id   = id.to_s
        instance.name = name
        instance
      rescue Mysql::Error
        nil
      end

      # Finds domain by given name and returns Domain instance.
      def find_by_name(name)
        domain_record = finder(:select => [:id, :name], :conditions => {:name => name})
        return nil if domain_record.nil?

        new(domain_record)
      end

      # Finds domain by given id and returns Domain instance.
      def find_by_id(id)
        domain_record = finder(:select => [:id, :name], :conditions => {:id => id})
        return nil unless domain_record

        new(domain_record)
      end
    end

    # Deletes current domain and all associated records.
    def destroy
      # Delete all associated records first
      MysqlAdapter.delete "DELETE FROM #{Record.table_name} WHERE domain_id = #{id}"

      # Then proceed with deletion
      super
    rescue Mysql::Error
      false
    end

    def equal?(domain)
      domain.id == id
    end

    # Returns current domain's SOA record.
    def soa_record
      Record.find_by_name_and_type(name, 'SOA')
    end
  end
end