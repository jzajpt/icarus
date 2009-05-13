require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class XmlRpc_PostfixBackendTest < Test::Unit::TestCase
  def setup
    @server = $server
  end
  
  def test_present?
    result = call_postfix('present?')
    assert_equal true, result
  end
  
  def test_name
    result = call_postfix('name')
    assert_equal 'Backends::Postfix', result
  end

  def test_domain_exists_with_invalid_domain
    result = call_postfix('domain_exists?', 'nonexistent.cz')
    assert_equal false, result
  end
  
  # TODO: write more tests
  
  protected

  def call_postfix(method, *args)
    arguments = ["postfix.#{method}"]
    arguments << args unless args.empty?
    @server.call(*arguments)
  end  
end