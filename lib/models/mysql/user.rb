#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../../stupid_record/record')

# To avoid conflict with Mysql class I'm using MySQL name (different letters casing) here,
# even through it doesn't follow convention used anywhere else in Icarus.

module MySQL

  # I'm not using StupidRecord here, because mysql user table doesnt have ids and 
  # doesn't follow some conventions used in StupidRecord.

  class User
    @@table_name = 'mysql.user'

    attr_accessor :host
    attr_accessor :name
    attr_accessor :password

    # Initializes instance attributes from record's hash.
    def initialize(attributes = nil)
      return unless attributes
      @host = attributes['Host']
      @name = attributes['User']
      @password = attributes['Password']
    end

    # Open up singleton
    class << self
      # Creates user with given name, password and host. Returns User instance or nil.
      def create(user, password, host)
        MysqlAdapter.execute "CREATE USER #{user}@'#{host}' IDENTIFIED BY '#{password}'"

        instance = new
        instance.host = host
        instance.name = user
        instance.password = password
        instance
      rescue Mysql::Error
        nil
      end

      # Finds user by username, returns User instance or nil.
      def find_by_username(username)
        attributes = MysqlAdapter.select_one "SELECT * FROM #{@@table_name} WHERE User = '#{username}'"
        return nil if attributes.nil?

        new(attributes)
      rescue Mysql::Error
        nil
      end

      # Finds user by username and host, returns User instance or nil.
      def find_by_username_and_host(username, host)
        attributes = MysqlAdapter.select_one "SELECT * FROM #{@@table_name} WHERE User = '#{username}' and Host = '#{host}'"
        return nil if attributes.nil?

        new(attributes)
      rescue Mysql::Error
        nil
      end
    end

    # Sets password for user, returns true or false.
    def set_password(password)
      MysqlAdapter.execute "SET PASSWORD FOR #{name}@'#{@host}' = PASSWORD('#{password}')"
      true
    rescue Mysql::Error
      false
    end

    # Destroy users, returns true or false.
    def destroy
      MysqlAdapter.execute "DROP USER #{name}@'#{host}'"
      true
    rescue Mysql::Error
      false
    end
  end
end