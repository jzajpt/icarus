require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Postfix::Alias finder", :shared => true do
  it "should return Postfix::Alias instance" do
    @alias.should be_kind_of(Postfix::Alias)
  end

  %w(id address goto domain).each do |attribute|  
    it "should set #{attribute} attribute as string" do
      @alias.send(attribute).should be_kind_of(String)
    end
  end
end

describe Postfix::Alias do
  before(:all) do
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/postfix.sql'))
    process_sql_file(File.join(File.dirname(__FILE__), '/../../../sql/postfix_test_data.sql'))
  end

  it "should have table_name class variable" do
    Postfix::Alias.table_name.should_not be_nil
  end

  describe "attributes" do
    before(:all) do
      @alias = Postfix::Alias.new
    end

    %w(id address goto domain).each do |attr|
      it "should have #{attr} getter" do
        @alias.should respond_to(attr)
      end

      it "should have #{attr} setter" do
        @alias.should respond_to("#{attr}=")
      end
    end
  end

  it "create should return nil when given domain doesn't exist" do
    Postfix::Alias.create('jzajpt@nonexistent.cz', 'someone@else.com').should be_nil
  end

  describe "create" do
    before(:all) do
      @address     = "test#{rand(10000)}@blueberry.cz"
      @goto = "someone@somewhere.com"

      @alias = Postfix::Alias.create(@address, @goto)
    end

    it_should_behave_like "Postfix::Alias finder"

    it "should assign goto attribute" do
      @alias.goto.should == @goto
    end

    it "should create mailbox SQL record" do
      @sql_record = MysqlAdapter.select_one "SELECT * FROM postfix_alias WHERE id = '#{@alias.id}'"
      @sql_record.should be_kind_of(Hash)

      # Multiple expections in one examples suck, but i'm just way too lazy to break this down
      @sql_record['address'].should == @address
      @sql_record['goto'].should == @goto
      @sql_record['domain'].should == 'blueberry.cz'
    end
  end

  describe "find_by_address" do
    before(:all) do
      @alias = Postfix::Alias.find_by_address('jzajpt@blueberry.cz')
    end

    it_should_behave_like "Postfix::Alias finder"

    it "should set address attribute" do
      @alias.address.should == 'jzajpt@blueberry.cz'
    end

    it "should set goto attribute" do
      @alias.goto.should == 'jzajpt@blueberry.cz'
    end
  end

  describe "find_by_address" do
    before(:all) do
      @alias = Postfix::Alias.find_by_address_and_goto('jzajpt@blueberry.cz', 'jzajpt@blueberry.cz')
    end

    it_should_behave_like "Postfix::Alias finder"

    it "should set address attribute" do
      @alias.address.should == 'jzajpt@blueberry.cz'
    end

    it "should set goto attribute" do
      @alias.goto.should == 'jzajpt@blueberry.cz'
    end
  end
end