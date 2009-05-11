require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Postfix::Domain finder", :shared => true do
  it "should return Postfix::Domain instance" do
    @domain.should be_kind_of(Postfix::Domain)
  end

  %w(id name description).each do |attribute|  
    it "should set #{attribute} attribute as string" do
      @domain.send(attribute).should be_kind_of(String)
    end
  end
end

describe Postfix::Domain do
  before(:all) do
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/postfix.sql'))
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/postfix_test_data.sql'))
  end

  it "should have table_name class variable" do
    Postfix::Domain.table_name.should_not be_nil
  end

  describe "attributes" do
    before(:all) do
      @domain = Postfix::Domain.new
    end

    %w(id name description).each do |attr|
      it "should have #{attr} getter" do
        @domain.should respond_to(attr)
      end

      it "should have #{attr} setter" do
        @domain.should respond_to("#{attr}=")
      end
    end
  end

  it "create should return nil when domain already exists" do
    Postfix::Domain.create('blueberry.cz').should be_nil
  end

  it "find_by_name should return nil when domain was not found" do
    Postfix::Domain.find_by_name('nonexistent.cz').should be_nil
  end

  it "find_by_name should return nil when malformed name specified" do
    Postfix::Domain.find_by_name("nonexistent\'.cz").should be_nil
  end

  it "find_by_id should return nil when domain was not found" do
    Postfix::Domain.find_by_id(9999).should be_nil
  end

  it "find_by_id should return nil even when malformed name specified" do
    Postfix::Domain.find_by_id('test').should be_nil
  end

  describe "create" do
    before(:all) do
      @name = "test#{rand(10000)}.cz"
      @domain = Postfix::Domain.create(@name)
    end

    it_should_behave_like "Postfix::Domain finder"

    it "should set name attribute on instance" do
      @domain.name.should == @name
    end

    it "should create domain SQL record" do
      @sql_record = MysqlAdapter.select_one "SELECT * FROM postfix_domain WHERE id = '#{@domain.id}'"
      @sql_record.should be_kind_of(Hash)

      # Multiple expections in one examples suck, but i'm just way too lazy to break this down
      @sql_record['domain'].should == @name
      @sql_record['description'].should match(/icarus/i)
    end
  end

  describe "find_by_name" do  
    before(:all) do
      @domain = Postfix::Domain.find_by_name('blueberry.cz')
    end

    it_should_behave_like "Postfix::Domain finder"

    it "should set id attribute" do
      @domain.id.should == '1'
    end

    it "should set name attribute" do
      @domain.name.should == 'blueberry.cz'
    end
  end

  describe "find_by_id" do
    before(:all) do
      @domain = Postfix::Domain.find_by_id(1)
    end

    it_should_behave_like "Postfix::Domain finder"

    it "should set id attribute" do
      @domain.id.should == '1'
    end

    it "should set name attribute" do
      @domain.name.should == 'blueberry.cz'
    end
  end

end