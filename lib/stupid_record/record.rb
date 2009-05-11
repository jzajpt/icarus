#!/usr/bin/env ruby -wKU

require File.join(File.dirname(__FILE__), '/attributes')

module StupidRecord
  class Record
    include Attributes

    # Table name as class instance variable
    class << self; attr_accessor :table_name; end

    # ID of record represented by this class.
    attribute :id

    class << self
      # Finds one record by given conditions.
      #
      # ==== Parameters
      #
      # * <tt>:select</tt> - When not specified <tt>'*'</tt> is used.
      # * <tt>:conditions</tt> - Required hash of conditions, for example: <tt>{:username => username}</tt>.
      def finder(args)
        args.assert_required_keys(:conditions)
        what  = args[:select] ? args[:select].join(', ') : '*'
        conds = args[:conditions].collect { |k, v| "#{k} = '#{v}'" }
        conds = conds.join(' AND ')

        MysqlAdapter.select_one "SELECT #{what} FROM #{table_name} WHERE #{conds}"
      rescue Mysql::Error
        nil
      end
    end

    # Initializes record attributes from hash.
    def initialize(attrs = {})
      attrs.each do |key, value|
        send "#{key}=", value.to_s if respond_to?("#{key}=")
      end
    end

    # Updates current record with given attributes. If id is not set or if
    # an error occurs returns false.
    def update(attributes)
      return false if !has_valid_id? || attributes.empty?

      # Update attributes on this instance
      attributes.each do |key, value|
        setter = :"#{key}="
        if respond_to?(setter)
          send(setter, value)
        else
          return false
        end
      end

      sets = attributes.collect { |k, v| "#{k} = '#{v}'" }
      sets = sets.join(', ')

      count = MysqlAdapter.update "UPDATE #{self.class.table_name} SET #{sets} WHERE id = #{self.id}"
      count == 1
    end

    # Destroys current record identified by id attribute. If id is not set or
    # if an errors occur returns false otherwise returns true.
    def destroy
      return false unless has_valid_id?

      count = MysqlAdapter.delete "DELETE FROM #{self.class.table_name} WHERE id = #{self.id}"
      count == 1
    rescue Mysql::Error
      false
    end

    # Returns true if the compared object has the same type and the same id.
    def ==(o)
      if o.is_a? StupidRecord
        @id == o.id
      else
        false
      end
    end

    protected

    def has_valid_id?
      @id && !@id.to_s.empty?
    end

    # Constructs SQL INSERT query from given attributes.
    def self.construct_sql_insert(attributes)
      columns = attributes.keys.join(', ')
      values  = attributes.values.collect { |v| "'#{v}'" }.join(", ")

      "INSERT INTO #{table_name}(#{columns}) VALUES(#{values})"
    end
  end
end