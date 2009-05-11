#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../models/mysql/database')
require File.expand_path(File.dirname(__FILE__) + '/../models/mysql/user')
require File.expand_path(File.dirname(__FILE__) + '/base')

module Backends
  class Mysql
    backend_module

    # Create new MySQL database with specified name and character set. Returns true or false.
    def create_database(name, charset)
      database = ::MySQL::Database.create(name, charset)
      !database.nil?
    end

    # Creates new MySQL user with specified username, password and host. Returns true or false.
    def create_user(username, password, host)
      user = ::MySQL::User.create(username, password, host)
      !user.nil?
    end

    # Finds given user and updates its attributes (password only for now).
    def update_user(user, host, attributes)
      attributes.symbolize_keys

      user = ::MySQL::User.find_by_username_and_host(user, host)
      return false if user.nil? || !attributes.include?(:password)
      !!user.set_password(attributes[:password])
    end

    # Deletes database with given name, returns true or false.
    def destroy_database(name)
      database = ::MySQL::Database.find_by_name(name)
      return false if database.nil?
      !!database.destroy
    end

    # Deletes user with specified name and host. Returns true or false. 
    def destroy_user(username, host)
      user = ::MySQL::User.find_by_username_and_host(username, host)
      return false if user.nil?
      !!user.destroy
    end

    # Returns an array with all databases names.
    def get_all_databases
      databases = ::MySQL::Database.find_all
      names = []
      databases.each do |database|
        names << database.name
      end
      names
    end

    # Returns true if user with given name (and host optionally) exists, otherwise returns false.
    def user_exists?(name, host = nil)
      user = host ? ::MySQL::User.find_by_username_and_host(name, host) : ::MySQL::User.find_by_username(name)
      !user.nil?
    end

    # Returns true if database with given name exists, otherwise returns false.
    def database_exists?(name)
      database = ::MySQL::Database.find_by_name(name)
      !database.nil?
    end
  end
end