#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

module Apache
  class Directive
    attr_accessor :name
    attr_accessor :value
    
    def dump
      "#{name} #{value}"
    end
  end
end