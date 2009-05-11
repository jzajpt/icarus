#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../../stupid_record/record')


module Postfix
  class Domain < StupidRecord::Record
    self.table_name = 'postfix_domain'

    attribute :name
    attribute :description

    # Initializes instance attributes from record's hash.
    def initialize(attributes = nil)
      return unless attributes
      self.id          = attributes['id'].to_s
      self.name        = attributes['domain']
      self.description = attributes['description']
    end

    # Open up singleton
    class << self
      def create(name)
        description = "#{name} created by icarus"
        id = MysqlAdapter.insert "INSERT INTO #{table_name}(domain, description, created, modified) VALUES
                            ('#{name}', '#{description}', now(), now())"

        instance             = new
        instance.id          = id.to_s
        instance.name        = name
        instance.description = description
        instance
      rescue Mysql::Error
        nil
      end

      # Finds domain with given name and returns Domain instance. If nothing is found returns nil.
      def find_by_name(name)
        domain_record = finder(
          :select => [:id, :domain, :description],
          :conditions => {:domain => name})
        return nil if domain_record.nil?

        new(domain_record)
      end

      # Finds domain with given id and returns Domain instance. If nothing is found returns nil.
      def find_by_id(id)
        domain_record = finder(
          :select => [:id, :domain, :description],
          :conditions => {:id => id})
        return nil if domain_record.nil?

        new(domain_record)
      end
    end

    # Deletes current domain and all associated aliases and mailboxes. 
    def destroy
      # Delete all associated aliases first
      MysqlAdapter.delete "DELETE FROM #{Alias.table_name} WHERE domain = '#{name}'"

      # Delete all associated mailboxes first
      MysqlAdapter.delete "DELETE FROM #{Mailbox.table_name} WHERE domain = '#{name}'"

      super
    rescue Mysql::Error
      false
    end
  end
end