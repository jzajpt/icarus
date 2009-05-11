require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Backends::PowerDns do
  before(:all) do
    process_sql_file(File.join(File.dirname(__FILE__), '/../../sql/powerdns.sql'))
    process_sql_file(File.join(File.dirname(__FILE__), '/../../sql/powerdns_test_data.sql'))

    @powerdns = Backends::PowerDns.new
  end

  it "should respond to present?" do
    @powerdns.present?.should == true
  end

  it "should respond to name" do
    @powerdns.name.should == 'Backends::PowerDns'
  end

  it "should respond to domain_exists?" do
    @powerdns.should respond_to(:domain_exists?)
  end

  describe "domain_exists?" do
    it "should return false when domain doesn't exist" do
      @powerdns.domain_exists?('nonexistent.cz').should == false
    end

    it "should return true when domain exists" do
      @powerdns.domain_exists?('blueberry.cz').should == true
    end
  end

  it "should respond to record_exists?" do
    @powerdns.should respond_to(:record_exists?)
  end

  describe "record_exists?" do
    it "should return false when record doesn't exist" do
      @powerdns.record_exists?('www.nonexistent.cz', 'A').should == false
    end

    it "should return true when record exists" do
      @powerdns.record_exists?('blueberry.cz', 'A').should == true
    end
  end

  it "should respond to create_domain" do
    @powerdns.should respond_to(:create_domain)
  end

  describe "create_domain" do
    it "should return false if domain already exists" do
      @powerdns.create_domain('blueberry.cz').should == false
    end

    it "should return true when domain was created" do
      name = "test#{rand(10000)}.cz"
      @powerdns.create_domain(name).should == true
      @powerdns.domain_exists?(name).should == true
    end
  end

  it "should respond to create_domain_with_soa_record" do
    @powerdns.should respond_to(:create_domain_with_soa_record)
  end

  describe "create_domain_with_soa_record" do
    it "should return false if domain already exists" do
      @powerdns.create_domain_with_soa_record('blueberry.cz').should == false
    end

    it "should create domain" do
      name = "test#{rand(10000)}.cz"
      @powerdns.create_domain_with_soa_record(name).should == true
      @powerdns.domain_exists?(name).should == true
    end

    it "should create SOA record" do
      name = "test#{rand(10000)}.cz"
      @powerdns.create_domain_with_soa_record(name).should == true
      @powerdns.record_exists?(name, 'SOA').should == true
    end
  end

  it "should respond to create_record" do
    @powerdns.should respond_to(:create_record)
  end

  describe "create_record" do
    it "should return false if domain doesn't exist" do
      @powerdns.create_record('nonexistent.cz', 'www.nonexistent.cz', 'A', '81.0.213.225', 600).should == false
    end

    it "should create given record" do
      @powerdns.create_record('blueberry.cz', 'www2.blueberry.cz', 'A', '81.0.213.225', 600).should == true
      @powerdns.record_exists?('www2.blueberry.cz', 'A').should == true
    end
  end

  it "should respond to update_record" do
    @powerdns.should respond_to(:update_record)
  end

  describe "update_record" do
    it "should return false when invalid record specified" do
      @powerdns.update_record('nonexistent.com', 'A', {:content => '1.2.3.4'}).
        should == false
    end    

    it "should return false when no attributes given" do
      @powerdns.update_record('www.blueberry.cz', 'A', {}).should == false
    end

    it "should return false when invalid attributes given" do
      @powerdns.update_record('www.blueberry.cz', 'A', {:invalid => 'value'}).
        should == false
    end

    it "should return true when valid attributes given" do
      @powerdns.update_record('www.blueberry.cz', 'A', {:ttl => 1200}).
        should == true
    end
  end

  it "should respond to destroy_domain" do
    @powerdns.should respond_to(:destroy_domain)
  end

  it "destroy_domain should return false if domain doesn't exist" do
    @powerdns.destroy_domain('www.nonexistent.cz').should == false
  end

  describe "successfull destroy_domain" do
    before(:each) do
      @response = @powerdns.destroy_domain('blueberry.cz')
    end

    it "should return true when successful" do
     @response.should == true
    end

    it "should destroy domain" do
      @powerdns.domain_exists?('blueberry.cz').should == false
    end

    it "should all domain records" do
      @powerdns.record_exists?('www.blueberry.cz', 'A').should == false
    end
  end

  it "should respond to destroy_record" do
    @powerdns.should respond_to(:destroy_record)
  end

  describe "destroy_record" do
    it "should return false if record doesn't exist" do
      @powerdns.destroy_record('www.nonexistent.cz', 'A').should == false
    end

    it "should return false if record doesn't exist" do
      @powerdns.destroy_record('www.blueberry.cz', 'AAAA').should == false
    end

    it "should return true and delete record" do
      @powerdns.destroy_record('bender.blueberry.cz', 'A').should == true
      @powerdns.record_exists?('bender.blueberry.cz', 'A').should == false
    end
  end  
end