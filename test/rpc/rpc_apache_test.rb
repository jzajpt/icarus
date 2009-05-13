require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class XmlRpc_SystemBackendTest < Test::Unit::TestCase
  def setup
    @server = $server
  end
  
  def test_present?
    result = call_apache('present?')
    assert_equal true, result
  end
  
  def test_name
    result = call_apache('name')
    assert_equal 'Backends::Apache', result
  end
  
  protected

  def call_apache(method, *args)
    arguments = ["apache.#{method}"]
    arguments << args unless args.empty?
    @server.call(*arguments)
  end  
end