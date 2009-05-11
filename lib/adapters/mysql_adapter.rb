#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2008 Jiri Zajpt
#

require 'mysql'
require 'logger'

class MysqlAdapter
  class ConnectionError < StandardError; end
  class NotConnectedError < StandardError; end
  class NoCredentialsError < StandardError; end

  class << self
    attr_accessor :connection
    attr_accessor :credentials
    attr_accessor :logger

    # Connects to MySQL database using values specified at initialization.
    def connect(credentials)
      raise ArgumentError unless credentials.is_a?(Hash)
      @credentials = credentials
      begin
        @connection = Mysql.new(@credentials[:host], @credentials[:user],
          @credentials[:password], @credentials[:database])
        true
      rescue ::Mysql::Error => e
        raise ConnectionError
      end
    end

    def retrieve_connection
      @connection or raise NotConnectedError
    end

    # Executes single SQL query.
    def execute(sql)
      @logger.debug("SQL:   #{sql}") if @logger
      retrieve_connection.query(sql)
    end

    def select(sql)
      result = execute(sql)
      rows = []
      result.each_hash { |row| rows << row }
      result.free
      rows
    end

    # Executes SELECT query which expects one row.
    def select_one(sql)
      result = execute(sql)
      result.fetch_hash
    end

    def insert(sql)
      execute(sql)
      retrieve_connection.insert_id
    end

    def update(sql)
      execute(sql)
      retrieve_connection.affected_rows
    end

    def delete(sql)
      update(sql)
    end

    # Returns true when connection to MySQL database is active.
    def connected?
      if @connection
        @connection.stat
        @connection.errno.zero?
      else
        false
      end
    end

    # Disconnects from MySQL database.
    def disconnect!
      retrieve_connection.close if @connection
      @connection = nil
      true
    end

    # Disconnects from MySQL database and then connects back again.
    def reconnect!
      raise NoCredentialsError unless @credentials
      disconnect!
      connect(@credentials)
    end
  end
end
