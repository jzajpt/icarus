require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'digest/sha2'

describe MysqlAdapter, "with valid credentials" do
  before(:all) do
    @valid_config = {
      :host => 'localhost',
      :user => 'root',
      :password => '', # This is supposed to be valid password
      :database => 'mysql_adapter_test'
    }
  end

  context "disconnected" do
    before(:each) do
      MysqlAdapter.disconnect!
    end

    it "should respond to connected" do
      MysqlAdapter.connected?.should == false
    end

    it "should connect" do
      MysqlAdapter.connect(@valid_config).should == true
    end

    it "should connect using reconnect!" do
      MysqlAdapter.connect(@valid_config).should == true
      MysqlAdapter.disconnect!
      MysqlAdapter.reconnect!.should == true
      MysqlAdapter.connected?.should == true
    end
  end

  context "connected" do
    before(:each) do
      MysqlAdapter.connect(@valid_config)
    end

    it "should respond to connected?" do
      MysqlAdapter.connected?.should == true
    end

    it "should reconnect" do
      MysqlAdapter.reconnect!.should == true
      MysqlAdapter.connected?.should == true
    end

    it "should disconnect" do
      MysqlAdapter.disconnect!.should == true
      MysqlAdapter.connected?.should == false
    end

    describe "execute method" do
      it "should execute query" do
        MysqlAdapter.execute("SELECT 1").should be_instance_of(Mysql::Result)
      end

      it "should raise Mysql::Error on invalid SQL query" do
        lambda { MysqlAdapter.execute("INVALID QUERY!") }.should raise_error(Mysql::Error)
      end
    end

    describe "select method" do
      it "should return array" do
        MysqlAdapter.select("SELECT 1").should be_instance_of(Array)
      end

      it "should raise Mysql::Error on invalid query" do
        lambda { MysqlAdapter.select("INVALID SELECT QUERY!") }.should raise_error(Mysql::Error)
      end
    end

    describe "select_one method" do
      it "should return hash" do
        MysqlAdapter.select_one("SELECT 1").should be_instance_of(Hash)
      end

      it "should raise Mysql::Error on invalid query" do
        lambda { MysqlAdapter.select_one("INVALID SELECT QUERY!") }.should raise_error(Mysql::Error)
      end
    end
  end

  context "connected with data" do
    before(:each) do
      MysqlAdapter.connect(@valid_config)

      @table_name = Digest::SHA2.hexdigest("#{Time.now}--#{rand}")
      MysqlAdapter.execute "CREATE TABLE #{@table_name}( id INT auto_increment PRIMARY KEY, value VARCHAR(255) )"
    end

    after(:each) do
      MysqlAdapter.execute "DROP TABLE #{@table_name}"
    end

    describe "insert method" do      
      it "should return id of inserted record" do
        MysqlAdapter.insert("INSERT INTO #{@table_name} VALUES(123, 'test1234')").should == 123
      end

      it "should raise Mysql::Error on invalid query" do
        lambda { MysqlAdapter.update("INVALID INSERT QUERY!") }.should raise_error(Mysql::Error)
      end
    end

    describe "update method" do
      before(:each) do
        @id = MysqlAdapter.insert("INSERT INTO #{@table_name}(value) VALUES('test1234')")
      end

      it "should return number of affected record" do
        MysqlAdapter.update("UPDATE #@table_name SET value = 'update test' WHERE id = #@id").should == 1
      end

      it "should raise Mysql::Error on invalid query" do
        lambda { MysqlAdapter.update("INVALID UPDATE QUERY!") }.should raise_error(Mysql::Error)
      end
    end

    describe "delete method" do
      before(:each) do
        @id = MysqlAdapter.insert("INSERT INTO #{@table_name}(value) VALUES('test1234')")
      end

      it "should return number of deleted records" do
        MysqlAdapter.delete("DELETE FROM #@table_name WHERE id = #@id").should == 1
      end

      it "should raise Mysql::Error on invalid query" do
        lambda { MysqlAdapter.delete("INVALID DELETE QUERY!") }.should raise_error(Mysql::Error)
      end
    end
  end
end

describe MysqlAdapter, "with invalid password" do
  before(:all) do
    MysqlAdapter.disconnect!
    @invalid_config = {
      :host => 'localhost',
      :user => 'root',
      :password => 'invalid_password', # This is supposed to be an invalid password!
      :database => 'mysql_adapter_test'
    }
  end

  it "should not be able to connect" do
    lambda { MysqlAdapter.connect(@invalid_config) }.should raise_error(MysqlAdapter::ConnectionError)
    MysqlAdapter.connected?.should == false
  end

  it "should not be able to connect using reconnect!" do
    lambda { MysqlAdapter.reconnect! }.should raise_error(MysqlAdapter::ConnectionError)
    MysqlAdapter.connected?.should == false
  end

  it "should not fail while calling disconnect!" do
    MysqlAdapter.disconnect!.should == true
    MysqlAdapter.connected?.should == false
  end

end