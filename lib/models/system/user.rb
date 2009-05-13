#!/usr/bin/ruby
#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2008 Jiri Zajpt
#

require 'fileutils'

module System
  class User
    # Unnormalized username format is username which *can*
    # be converted to normalized format without any significant
    # losses.
    UNNORMALIZED_USERNAME_FORMAT = /\A[a-z_][a-z0-9\._-]*\Z/i
    
    # Username format which can be supplied to useradd with
    # no problems.
    USERNAME_FORMAT = /\A[a-z_][a-z0-9_-]*\Z/
    
    # Maximum length of username.
    MAX_USERNAME_LENGTH = 32

    # Locations of useradd, userdel binaries and of passwd file.
    @useradd = '/usr/sbin/useradd'
    @userdel = '/usr/sbin/userdel'
    @passwd  = '/etc/passwd'  

    class << self
      attr_accessor :useradd, :userdel, :passwd
      
      # Finds user in passwd file and returns User object.
      def find_by_name(username)
        # Open password file, read line by line
        File.open(@passwd, 'r') do |file|
          file.readlines.each do |line|
            fields = line.strip.split(':')
            if fields[0] == username
              user = User.new
              user.username    = fields[0]
              user.uid         = fields[2].to_i
              user.gid         = fields[3].to_i
              user.description = fields[4]
              user.home        = fields[5]
              user.shell       = fields[6]
              return user
            end
          end
        end
        nil
      end

      # Creates user with given username and options.
      #
      # Possible options:
      #   - home, create_home, shell, description, :normalize_username
      def create(username, options = {})
        unless File.exists? @useradd
          raise "useradd binary '#{@useradd}' doesn't exist."
        end

        if options.has_key?(:normalize_username) && options[:normalize_username]
          username = normalize_username username
        end

        if !username.match(USERNAME_FORMAT) || username.length > MAX_USERNAME_LENGTH
          return false
        end

        params = []
        params << "-m"                            if options.has_key?(:create_home) && options[:create_home]
        params << "-d #{options[:home]}"          if options.has_key? :home
        params << "-s #{options[:shell]}"         if options.has_key? :shell
        params << "-c '#{options[:description]}'" if options.has_key? :description

        `#{@useradd} #{params.join(' ')} #{username}`
        $?.exitstatus == 0
      end

      # Deletes given user.
      def delete(username, options = {})
        unless File.exists? @userdel
          raise "userdel binary '#{@userdel}' doesn't exist."
        end

        `#{@userdel} #{username}`
        $?.exitstatus == 0
      end

      # Returns normalized username format, if given username
      # can be normalized without any significant losses.
      def normalize_username(username)
        if username.match UNNORMALIZED_USERNAME_FORMAT
          username.downcase.gsub('.', '_')
        else
          nil
        end
      end
    end
    
    attr_accessor :username
    attr_accessor :uid, :gid
    attr_accessor :description
    attr_accessor :home
    attr_accessor :shell

    def initialize(username = nil)
      @username = username if username
    end
  end

end
