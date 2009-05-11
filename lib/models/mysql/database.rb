#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../../stupid_record/record')
require File.expand_path(File.dirname(__FILE__) + '/user')


# To avoid conflict with Mysql class I'm using MySQL name (different letters casing) here,
# even through it doesn't follow convention used anywhere else in Icarus.

module MySQL
  class Database
    @@table_name = 'mysql.user'

    attr_accessor :name
    attr_accessor :character_set

    # Open up singleton
    class << self
      # Creates new MySQL database with given name and charset and returns Database instance or nil.
      def create(name, character_set = 'utf8')
        MysqlAdapter.execute "CREATE DATABASE #{name} CHARACTER SET = #{character_set}"

        instance = new
        instance.name = name
        instance.character_set = character_set
        instance
      rescue Mysql::Error
        nil
      end

      # Finds all databases and returns an array with instances of Database. If no database are
      # found, returns an empty array.
      def find_all
        result = MysqlAdapter.execute "SHOW DATABASES"
        return [] if result.num_rows == 0

        array = []
        while row = result.fetch_row
          instance = new
          instance.name = row[0]
          array << instance
        end

        array
      end

      # Finds database with given name and returns Database instance or nil. 
      def find_by_name(name)
        result = MysqlAdapter.execute "SHOW DATABASES LIKE '#{name}'"
        row = result.fetch_row
        return nil if result.num_rows == 0

        instance = new
        instance.name = row[0]
        instance
      rescue Mysql::Error
        nil
      end
    end

    # Grants all privileges (GRANT ALL) to given user. Returns true or false.
    def grant_all_to(user)
      return false if user.nil? && !user.is_a?(MySQL::User)
      MysqlAdapter.execute "GRANT ALL ON #{name}.* TO #{user.name}@'#{user.host}'"
      true
    rescue Mysql::Error
      false
    end

    # Returns byte size of database.
    def size
      tables = MysqlAdapter.select "SHOW TABLE STATUS FROM #{name}"

      size = 0
      tables.each do |table|
        size += table['Data_length'].to_i + table['Index_length'].to_i
      end

      size
    end

    # Destroys database, returns true or false.
    def destroy
      MysqlAdapter.execute "DROP DATABASE #{name}"
      true
    rescue Mysql::Error
      false
    end
  end
end