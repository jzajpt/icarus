#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require 'base64'
require 'digest/sha2'
require File.expand_path(File.dirname(__FILE__) + '/../../stupid_record/record')


module Proftpd
  class FtpAccount < StupidRecord::Record
    self.table_name = 'proftpd'

    attribute :username
    attribute :password
    attribute :uid
    attribute :gid
    attribute :ftpdir
    attribute :homedir
    attribute :valid_until

    # Open up singleton
    class << self
      def create(attributes)
        return nil unless attributes.has_keys?(:username, :password, :domain)

        sql_attributes = prepare_sql_attributes attributes
        sql_attributes[:id] = MysqlAdapter.insert construct_sql_insert(sql_attributes)

        new(sql_attributes)
      rescue Mysql::Error
        nil
      end

      # Finds ftp account by given username, returns FtpAccount instance or nil.
      def find_by_username(username)
        attributes = finder(
          :select => [:id, :username, :password, :uid, :gid, :ftpdir, :homedir, :valid_until],
          :conditions => {:username => username})
        return nil if attributes.nil?

        new(attributes)
      end
    end

    def password=(pwd)
      @password = "{sha1}#{[Digest::SHA1.digest(pwd)].pack('m').strip}"
    end

    protected

    def self.prepare_sql_attributes(attributes)
      sql_attrs = {}
      sql_attrs[:username] = attributes[:username]
      sql_attrs[:password] = "{sha1}#{[Digest::SHA1.digest(attributes[:password])].pack('m').strip}"
      sql_attrs[:ftpdir]   = interpolate_path(attributes)
      sql_attrs[:homedir]  = sql_attrs[:ftpdir]
      # TODO: Set gid & uid 
      sql_attrs[:uid]      = 5000
      sql_attrs[:gid]      = 5000

      sql_attrs.delete(:domain)
      sql_attrs.delete(:subdomain)
      sql_attrs.delete(:directory)
      sql_attrs
    end

    def self.interpolate_path(attributes)
      path = IcarusConfig[:proftpd][:path]
      path.gsub!(/:domain/, attributes[:domain])
      path.gsub!(/:subdomain/, attributes[:subdomain]) if attributes[:subdomain]
      path << attributes[:directory] if attributes[:directory]
      path
    end
  end
end