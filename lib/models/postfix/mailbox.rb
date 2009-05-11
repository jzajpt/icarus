#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require 'base64'
require 'digest/sha2'
require File.expand_path(File.dirname(__FILE__) + '/../../stupid_record/record')
require File.expand_path(File.dirname(__FILE__) + '/domain')
require File.expand_path(File.dirname(__FILE__) + '/alias')

module Postfix
  class Mailbox < StupidRecord::Record
    self.table_name = 'postfix_mailbox'

    attribute :username
    attribute :name
    attribute :domain
    attribute :password
    attribute :maildir
    attribute :homedir
    attribute :quota

    # Open up singleton
    class << self
      # Creates new mailbox with given username and password and returns Mailbox instance.
      # Checks if domain in username exists, also checks for existing mailbox with same name.
      def create(username, password, quota, name = nil)
        user, domain = username.split('@')

        # Check for postfix domain record
        domain_record = Domain.find_by_name(domain)
        return nil if domain_record.nil? 

        # Check if mailbox doesn't already exist
        mailbox = Mailbox.find_by_username(username)
        return nil if mailbox

        password = hash_password(password)
        maildir  = "#{domain}/#{user}/"
        homedir  = IcarusConfig[:postfix][:prefix]

        id = MysqlAdapter.insert "INSERT INTO #{table_name}(username, password, name, maildir, homedir, domain, quota, created, modified) VALUES
                            ('#{username}', '#{password}', '#{name}', '#{maildir}', '#{homedir}', '#{domain}', #{quota}, now(), now())"

        # Create mailbox alias
        malias = Alias.create(username, username)
        return nil if malias.nil?

        # Setup instance
        instance           = new
        instance.id        = id.to_s
        instance.username  = username
        instance.domain    = domain
        instance.name      = name
        instance.password  = password
        instance.maildir   = maildir
        instance.homedir   = homedir
        instance.quota     = quota.to_s

        instance.setup_directories

        instance
      rescue Mysql::Error
        nil
      end


      # Finds mailbox with given username and returns Mailbox instance. If nothing is found, returns nil.
      def find_by_username(username)
        mailbox_record = finder(:select => [:id, :username, :password, :name, :domain, :maildir, :homedir, :quota],
                                :conditions => {:username => username})
        return nil if mailbox_record.nil?

        new(mailbox_record)
      end

      # Finds mailbox with given id and returns Mailbox instance.
      def find_by_id(id)
        mailbox_record = finder(:select => [:id, :username, :password, :name, :domain, :maildir, :homedir, :quota],
                                :conditions => {:id => id})

        return nil if mailbox_record.nil?

        new(mailbox_record)
      end
    end

    # Setups necessary postfix directories and creates following maildirs:
    #
    #   Trash
    #   Sent
    #   Drafts
    #   Spam
    def setup_directories
      require 'fileutils'

      path = File.join(homedir, maildir)
      create_maildir path
      create_maildir File.join(path, '.Trash')
      create_maildir File.join(path, '.Sent')
      create_maildir File.join(path, '.Drafts')
      create_maildir File.join(path, '.Spam')

      FileUtils.mkdir_p(path)
      FileUtils.chown_R(IcarusConfig[:postfix][:user], IcarusConfig[:postfix][:group], path)
      FileUtils.chmod_R(0750, path)
    end

    def to_s
      "Mailbox: id=#{@id}, username=#{@username}"
    end

    protected

    # Hashes given password using SHA256 and encodes it using Base64 coding.
    def self.hash_password(password)
      Base64.encode64(Digest::SHA2.digest(password)).strip
    end

    # Creates maildir in given path (maildirmake wrapper).
    def create_maildir(path)
      `#{IcarusConfig[:postfix][:maildirmake]} #{path}`
      $?.exitstatus == 0
    end

  end
end