require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hash do
  context "#symbolize_keys" do
    it "should convert all string keys to symbols" do
      hash = {'key' => :value}
      symbolized_hash = hash.symbolize_keys
      symbolized_hash.keys.should == [:key]
    end

    it "shouldn't convert symbol keys to symbols" do
      hash = {:key => 'value'}
      symbolized_hash = hash.symbolize_keys
      symbolized_hash.keys.should == [:key]
    end

    it "should not modify original hash" do
      hash = {'key' => 'value'}
      symbolized_hash = hash.symbolize_keys
      hash.keys.should == ['key']
    end

    it "shouldn't' fail on non symbol or string key" do
      object = Object.new
      hash = {object => 'value'}
      symbolized_hash = hash.symbolize_keys
      hash.keys.should == [object]
    end
  end

  context "#symbolize_keys!" do
    it "should convert all string keys to symbols" do
      hash = { 'key' => 'value' }
      hash.symbolize_keys!
      hash.keys.should == [:key]
    end

    it "shouldn't convert symbol keys to symbols" do
      hash = { :key => 'value' }
      hash.symbolize_keys!
      hash.keys.should == [:key]
    end
  end

  # TODO: test the rest
end