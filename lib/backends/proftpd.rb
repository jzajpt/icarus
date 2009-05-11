#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../models/proftpd/ftp_account')
require File.expand_path(File.dirname(__FILE__) + '/base')

module Backends
  class Proftpd
    backend_module

    # Creates ftp account with given attributes and returns true or false.
    def create_ftp_account(attributes)
      ftp_account = ::Proftpd::FtpAccount.create(attributes)
      !ftp_account.nil?
    end

    # Updates ftp account found by username with given attributes.
    def update_ftp_account(username, attributes)
      ftp_account = ::Proftpd::FtpAccount.find_by_username(username)
      return false if ftp_account.nil?
      !!ftp_account.update(attributes)
    end

    # Deletes given ftp account and returns true if everything went fine.
    def destroy_ftp_account(username)
      ftp_account = ::Proftpd::FtpAccount.find_by_username(username)
      return false if ftp_account.nil?
      !!ftp_account.destroy
    end

    # Returns true if ftp account with given username exists.
    def ftp_account_exists?(username)
      ftp_account = ::Proftpd::FtpAccount.find_by_username(username)
      !ftp_account.nil?
    end
  end
end