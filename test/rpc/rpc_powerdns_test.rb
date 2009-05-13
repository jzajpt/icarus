require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class XmlRpc_PowerDnsBackendTest < Test::Unit::TestCase
  def setup
    @server = $server
  end

  def test_present?
    result = call_powerdns('present?')
    assert_equal true, result
  end
  
  def test_name
    result = call_powerdns('name')
    assert_equal result, 'Backends::PowerDns'    
  end
  
  def test_create_domain
    result = call_powerdns('create_domain', 'first.cz')
    assert_equal true, result
  end
  
  def test_create_domain_with_soa_record
    result = call_powerdns('create_domain_with_soa_record', 'firstwithsoa.cz')
    assert_equal true, result
  end
  
  def test_create_record
    result = call_powerdns('create_record', 'first.cz', 'www.first.cz', 'A', '81.0.213.225', 600)
    assert_equal true, result
  end
  
  def test_create_record_with_invalid_domain
    result = call_powerdns('create_record', 'nonexistent.cz', 'www.first.cz', 'A', '81.0.213.225', 600)
    assert_equal false, result
  end
  
  def test_domain_exists_with_invalid_domain
    result = call_powerdns('domain_exists?', 'nonexistent.cz')
    assert_equal false, result
  end
  
  def test_record_exists_with_invalid_record
    result = call_powerdns('record_exists?', 'www.nonexistent.cz', 'A')
    assert_equal false, result
  end
  
  protected

  def call_powerdns(method, *args)
    arguments = ["powerdns.#{method}"]
    arguments << args unless args.empty?
    @server.call(*arguments)
  end  
end
