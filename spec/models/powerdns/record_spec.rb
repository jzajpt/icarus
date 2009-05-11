require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "PowerDNS::Record finder", :shared => true do
  it "should return PowerDns::Record instance" do
    @record.should be_kind_of(PowerDns::Record)
  end

  %w(id domain_id name type content ttl).each do |attribute|
    it "should set #{attribute} attribute as string" do
      @record.send(attribute).should be_kind_of(String)
    end
  end
end


describe PowerDns::Record do
  before(:all) do
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/powerdns.sql'))
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/powerdns_test_data.sql'))
  end

  it "should have table_name class variable" do
    PowerDns::Record.table_name.should_not == nil
  end

  describe "attributes" do
    before(:all) do
      @record = PowerDns::Record.new
    end

    %w(id name type content domain_id ttl prio).each do |attr|
      it "should have #{attr} getter" do
        @record.should respond_to(attr)
      end

      it "should have #{attr} setter" do
        @record.should respond_to("#{attr}=")
      end
    end
  end

  it "create should return nil when empty attributes given" do
    PowerDns::Record.create({}).should == nil
  end

  it "create should return nil when given domain doesn't exist" do
    PowerDns::Record.create(:domain_id => 999, :name => 'www.nonexistent.cz', 
      :type => 'A', :content => '81.0.213.225', :ttl => 600, :prio => 10).should == nil
  end

  it "create should return nil when given record already exists" do
    PowerDns::Record.create(:domain_id => 1, :name => 'www.blueberry.cz',
      :type => 'A', :content => '81.0.213.225', :ttl => 600, :prio => 10).should == nil
  end

  it "create should return nil malformed attribute(s) was specified" do
    PowerDns::Record.create(:domain_id => 1, :name => '\'www2.blueberry.cz',
      :type => 'A', :content => '81.0.213.225', :ttl => 600, :prio => 10).should == nil
  end

  it "should respond to create" do
    PowerDns::Record.should respond_to(:create)
  end

  describe "create" do
    before(:all) do
      @name = "www.test#{rand(10000)}.cz"
      @record = PowerDns::Record.create :domain_id => 1, :name => @name, 
        :type => 'A', :content => '1.2.3.4', :ttl => 600, :prio => 10
    end

    it_should_behave_like "PowerDNS::Record finder"

    it "should set domain_id attribute on instance" do
      @record.domain_id.should == '1'
    end

    it "should set name attribute on instance" do
      @record.name.should == @name
    end

    it "should set type attribute on instance" do
      @record.type.should == 'A'
    end

    it "should set content attribute on instance" do
      @record.content.should == '1.2.3.4'
    end

    it "should set ttl attribute on instance" do
      @record.ttl.should == '600'
    end

    it "should set prio attribute on instance" do
      @record.prio.should == '10'
    end

    it "should create SQL record" do
      @sql_record = MysqlAdapter.select_one "SELECT * FROM records WHERE id = '#{@record.id}'"
      @sql_record.should be_kind_of(Hash)

      # Multiple expections in one examples suck, but i'm just way too lazy to break this down
      @sql_record['name'].should == @name
      @sql_record['domain_id'].should == '1'
      @sql_record['type'].should == 'A'
      @sql_record['content'].should == '1.2.3.4'
      @sql_record['ttl'].should == '600'
      # @sql_record['prio'].should == '10'
    end
  end

  it "should respond to find_by_name_and_type" do
    PowerDns::Record.should respond_to(:find_by_name_and_type)
  end

  describe "find_by_name_and_type given invalid attributes" do
    it "return nil when record was not found" do
      PowerDns::Record.find_by_name_and_type('www.nonexistent.cz', 'A').should == nil
    end

    it "return nil when malformed input was given" do
      PowerDns::Record.find_by_name_and_type("www.nonexistent.cz\'", 'A').should == nil
    end
  end

  describe "find_by_name_and_type given valid attributes" do
    before(:all) do
      @record = PowerDns::Record.find_by_name_and_type('www.blueberry.cz', 'A')
    end

    it_should_behave_like "PowerDNS::Record finder"

    it "should set domain_id attribute" do
      @record.domain_id.should == '1'
    end

    it "should set name attribute" do
      @record.name.should == 'www.blueberry.cz'
    end

    it "should set type attribute" do
      @record.type.should == 'A'
    end

    it "should set content attribute" do
      @record.content.should == '81.0.213.225'
    end

    it "should set ttl attribute" do
      @record.ttl.should == '120'
    end
  end

  it "should respond to find_by_name_and_type_and_content" do
    PowerDns::Record.should respond_to(:find_by_name_and_type_and_content)
  end

  describe "find_by_name_and_type_and_content given invalid attributes" do
    it "return nil when record was not found" do
      PowerDns::Record.find_by_name_and_type_and_content('www.nonexistent.cz', 'A', '0.0.0.0').should == nil
    end

    it "return nil when malformed domain was given" do
      PowerDns::Record.find_by_name_and_type_and_content("www.nonexistent.cz\'", 'A', '0.0.0.0').should == nil
    end

    it "return nil when malformed type was given" do
      PowerDns::Record.find_by_name_and_type_and_content("www.nonexistent.cz", "A'", '0.0.0.0').should == nil
    end
  end

  describe "find_by_name_and_type_and_content given valid attributes" do
    before(:all) do
      @record = PowerDns::Record.find_by_name_and_type_and_content('www.blueberry.cz', 'A', '81.0.213.225')
    end

    it_should_behave_like "PowerDNS::Record finder"
  end

  describe "successful destroy" do
    before(:all) do
      @record = PowerDns::Record.find_by_name_and_type('www.blueberry.cz', 'A')
    end

    it "should return true" do
      @record.destroy.should == true
    end
  end


  describe "domain method" do
    before(:each) do
      @record = PowerDns::Record.find_by_name_and_type('blueberry.cz', 'A')
    end

    it "should return PowerDns::Domain instance" do
      @record.domain.should be_kind_of(PowerDns::Domain)
    end

    it "should return right domain object" do
      @domain = PowerDns::Domain.find_by_name('blueberry.cz')
      @record.domain.should equal(@domain)
    end
  end
end