#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

require 'sys/admin'
require 'sys/uptime'
require File.expand_path(File.dirname(__FILE__) + '/base')

module Backends
  class System
    backend_module

    # Simple echo service, returns string given as argument.
    def echo(string)
      string
    end

    # Ping service, returns 'pong' string.
    def ping
      'pong'
    end

    # Returns uname of system.
    def uname
      `uname -a`
    end

    # Returns uptime in format of colon separated string (days:hours:minutes:seconds).
    def uptime
      Sys::Uptime.uptime
    end

    # Returns true when given user exist otherwise returns false.
    def user_exists?(username)
      Sys::Admin.get_user(username)
      true
    rescue
      false
    end

    # Returns true when given group exist otherwise returns false.
    def group_exists?(group)
      Sys::Admin.get_group(group)
      true
    rescue
      false
    end
  end
end