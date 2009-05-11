require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StupidRecord::Record do

  before(:all) do
    class RecordTest < StupidRecord::Record
      attribute :key
      attribute :value
    end
  end

  it "should have id class accessor" do
    StupidRecord::Record.table_name = 'test'
    StupidRecord::Record.table_name.should == 'test'
  end

  it "should respond to finder" do
    StupidRecord::Record.should respond_to(:finder)
  end

  describe "finder method" do
    it "should raise ArgumentError when no :conditions is specified" do
      lambda { StupidRecord::Record.finder({}) }.should raise_error(ArgumentError)
    end

    it "should construct whole SQL query" do
      StupidRecord::Record.table_name = 'testing'

      MysqlAdapter.should_receive(:select_one).
        with(match(/select \* from testing where a = 'b'/i)).once
      StupidRecord::Record.finder(:conditions => {:a => 'b'})
    end

    it "should construct SQL WHERE conditions" do
      StupidRecord::Record.table_name = 'test'

      MysqlAdapter.should_receive(:select_one).with(match(/a = 'b'/i)).once
      StupidRecord::Record.finder(:conditions => {:a => 'b'})
    end
  end

  describe 'new method' do
    before(:all) do  
      @record = RecordTest.new(:id => 123, :key => 'a', :value => 'b')
    end

    it "should set id attribute as string" do
      @record.id.should == '123'
    end

    it "should set key attribute as string" do
      @record.key.should == 'a'
    end

    it "should set value attribute as string" do
      @record.value.should == 'b'
    end
  end


  it "should construct SQL INSERT query from attributes" do
    RecordTest.table_name = 'testing'
    query = RecordTest.construct_sql_insert(:id => 1234, :key => 'a', :value => 'b')
    query.should match(/INSERT INTO testing\(.*\) VALUES\('.*', '.*', '.*'\)/i)
  end

  describe "instance" do

    before(:each) do
      class RecordTest < StupidRecord::Record
        attribute :key
        attribute :value
      end

      @record = RecordTest.new
    end

    it "should respond_to id" do
      @record.should respond_to(:id)
    end

    it "should respond_to id=" do
      @record.should respond_to(:id=)
    end

    it "should remember id" do
      @record.id = 1234
      @record.id.should == 1234
    end

    describe "equality" do
      before(:all) do
        @new_record = RecordTest.new :id => 321
        @same_record = RecordTest.new :id => 321
        @other_record = RecordTest.new :id => 666
      end

      it "should return false when any non record object specified" do
        (@new_record == []).should == false
        (@new_record == {}).should == false
        (@new_record == 1).should == false
        (@new_record == '1').should == false
      end

      it "should return false when other id" do
        (@new_record == @other_record).should == false
      end

      it "should return true when record with same id given" do
        (@new_record == @same_record).should == true
      end
    end

    it "should respond to update" do
      @record.should respond_to(:update)
    end

    describe "#update" do
      it "should return false when it has no id attribute" do
        @record.update({}).should == false
      end

      it "should return false when it has id attribute and empty attributes given" do
        @record.id = 1
        @record.update({}).should == false
      end

      it "should raise ArgumentError when unknown attributes given" do
        @record.update :unknown => 'v'
      end

      it "should return false when attributes given but it has no id" do
        @record.update({:key => 'newkey'}).should == false
      end

      it "should return true when valid attributes given" do
        @record.id = 123
        MysqlAdapter.should_receive(:update).
          with(/\Aupdate testing set key = 'newkey' where id = 123\Z/i).
          once.and_return(1)
        @record.update(:key => 'newkey').should == true
      end

      it "should update attributes in instance" do
        @record.id = 123
        MysqlAdapter.should_receive(:update).with(anything).once.and_return(1)
        @record.update(:key => 'newkey').should == true
        @record.key.should == 'newkey'
      end
    end

    it "should respond to destroy" do
      @record.should respond_to(:destroy)
    end

    describe "#destroy" do
      it "should return nil when no id is specified" do
        @record.id = nil
        @record.destroy.should be_false
      end

      it "should return nil when no table_name is specified" do
        @record.class.table_name = nil
        @record.destroy.should be_false
      end

      it "should call SQL query DELETE" do
        @record.id = 123
        @record.class.table_name = 'testing'
        MysqlAdapter.should_receive(:delete).with(/\Adelete from testing where id = 123\Z/i).
          once.and_return(1)
        @record.destroy
      end
    end

  end

end