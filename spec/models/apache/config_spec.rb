require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Apache::Config do
  it "should raise ArgumentError when invalid filename given" do
    lambda { Apache::Config.new('nonexistent.conf') }.should raise_error(ArgumentError)
  end

  context "initiated from config file" do
    before(:all) do
      # All these examples depends on content of apache_config.conf file, so beware.
      @config_file = File.expand_path(File.dirname(__FILE__) + '/../../../test/virtual_host.conf')
      @apache_config = Apache::Config.new(@config_file)
    end

    it "should respond_to file_name" do
      @apache_config.should respond_to(:file_name)
    end 

    it "should return config file name" do
      @apache_config.file_name.should == @config_file
    end

    it "should have 0 directives" do
      @apache_config.directives.size.should == 0
    end

    it "should have 1 section" do
      @apache_config.sections.size.should == 1
      @apache_config.sections.first.name.should == 'VirtualHost'
    end

    it "should find section by name" do
      @apache_config.find_section_by_name('VirtualHost').should be_kind_of(Apache::Section)
    end

    it "should dump config" do
      puts @apache_config.dump
    end
  end
end