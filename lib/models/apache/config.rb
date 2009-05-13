#
# Author::    Jiri Zajpt  (mailto:jzajpt@blueberry.cz)
# Copyright:: Copyright (c) 2009 Jiri Zajpt
#

module Apache
  class Config
    attr_accessor :file_name
    attr_accessor :config
    attr_accessor :directives
    attr_accessor :sections
    
    def initialize(file_name)
      @config = File.read(file_name)
      @file_name = file_name
      @sections = []
      @directives = []

      load_config
    rescue Errno::ENOENT
      raise ArgumentError.new('Invalid config file given')
    end
    
    def find_section_by_name(name)
      sections.each do |section|
        return section if section.name.downcase == name.downcase
      end
      nil
    end
    
    def dump
      string = ""
      directives.each do |directive|
        string << "#{directive.dump}\n"
      end
      sections.each do |section|
        string << "#{section.dump}\n"
      end
      string
    end
    
    protected
    
    def load_config
      @contexts = []

      @config.each_line do |line|
        clean_line! line
        next if line == nil

        case line
        # <Command params> (section opening directive)
        when /\A<[A-Za-z]/; create_section_from_line(line)
        # </Command> (section closing directive)
        when /\A<\//; @contexts.pop
        # Command params (directive)
        else create_directive_from_line(line)
        end
      end
    end

    def clean_line!(line)
      line.strip!
      
  	  return nil if line == ''
	  
  	  comment = line.index '#'
      line = line[0,comment] if comment

  	  return nil if line == ''

      line.strip!
    end
    
    def create_section_from_line(line)
      tokens = line.delete('<').delete('>').split(' ')
      section = Apache::Section.new
      section.name = tokens.shift
      section.value = tokens.join(' ')
      (@contexts.size > 0 ? @contexts.last.directives : @sections) << section
      @contexts << section
    end

    def create_directive_from_line(line)
      tokens = line.split(' ')
      directive = Apache::Directive.new
      directive.name = tokens.shift
      directive.value = tokens.join(' ')
      (@contexts.size > 0 ? @contexts.last.directives : @directives) << directive
    end
  end
end
