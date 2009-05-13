#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

module Apache
  class Section
    attr_accessor :name
    attr_accessor :value
    attr_accessor :directives
    attr_accessor :sections
    
    def initialize
      @directives = []
      @sections = []
    end
    
    def find_directive_by_name(name)
      directives.each do |directive|
        return directive if directive.name.downcase == name.downcase
      end
      nil
    end
    
    def find_directives_by_name(name)
      found = []
      directives.each do |directive|
        found << directive if directive.name.downcase == name.downcase
      end
      found
    end
    
    def has_directive?(name)
      directives.each do |directive|
        return true if directive.name.downcase == name.downcase
      end
      false
    end
    
    def dump
      string = "<#{name} #{value}>\n"
      directives.each do |directive|
        string << "#{directive.dump}\n"
      end
      sections.each do |section|
        string << "#{section.dump}\n"
      end
      string << "</#{name}>"
      string
    end
  end
end