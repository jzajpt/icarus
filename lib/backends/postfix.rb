#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require File.expand_path(File.dirname(__FILE__) + '/../models/postfix/domain')
require File.expand_path(File.dirname(__FILE__) + '/../models/postfix/mailbox')
require File.expand_path(File.dirname(__FILE__) + '/../models/postfix/alias')
require File.expand_path(File.dirname(__FILE__) + '/base')

module Backends
  class Postfix
    backend_module

    # Creates domain relay record Postfix.
    def create_domain(name)
      domain = ::Postfix::Domain.create(name)
      !domain.nil?
    end

    # Creates mailbox with given password and quota.
    def create_mailbox(username, password, quota)
      mailbox = ::Postfix::Mailbox.create(username, password, quota)
      !mailbox.nil?
    end

    # Creates alias, returns true or false.
    def create_alias(address, goto)
      malias = ::Postfix::Alias.create(address, goto)
      !malias.nil?
    end

    # Destroys domain and all associated mailboxes and aliases, returns true or false.
    # Leaves all data untouched, deletes only Postfix's records.
    def destroy_domain(name)
      domain = ::Postfix::Domain.find_by_name(name)
      return false if domain.nil?
      !!domain.destroy
    end

    # Destroys given mailbox, leaves data untouched and returns true or false
    def destroy_mailbox(username)
      mailbox = ::Postfix::Mailbox.find_by_username(username)
      return false if mailbox.nil?
      !!mailbox.destroy
    end

    # Destroys given alias, returns true or false.
    def destroy_alias(address, goto)
      malias = ::Postfix::Alias.find_by_address_and_goto(address, goto)
      return false if malias.nil?
      !!malias.destroy
    end

    # Returns true if domain with given name exists, otherwise false.
    def domain_exists?(domain)
      domain = ::Postfix::Domain.find_by_name(domain)
      !domain.nil?
    end

    # Returns true if mailbox with given username exists, otherwise false.
    def mailbox_exists?(username)
      mailbox = ::Postfix::Mailbox.find_by_username(username)
      !mailbox.nil?
    end

    # Returns true if alias with given address (and goto if specified) exists, otherwise false.
    def alias_exists?(address, goto = nil)
      malias = if goto
        ::Postfix::Alias.find_by_address_and_goto(address, goto)
      else
        ::Postfix::Alias.find_by_address(address)
      end
      !malias.nil?
    end
  end
end