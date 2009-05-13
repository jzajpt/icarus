require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class XmlRpc_SystemBackendTest < Test::Unit::TestCase
  def setup
    @server = $server
  end
  
  def test_present?
    result = @server.call('system.present?')
    assert result
  end
  
  def test_name
    result = @server.call('system.name')
    assert_equal result, 'Backends::System'    
  end
  
  def test_echo
    hash   = Digest::SHA2.hexdigest("#{Time.now}--#{rand}")
    result = @server.call('system.echo', hash)
    assert_equal result, hash    
  end
  
  def test_pong
    result = @server.call('system.ping')
    assert_equal result, 'pong'
  end
  
  def test_uname
    result = @server.call('system.uname')
    assert_not_nil result
  end
  
  def test_uptime
    result = @server.call('system.uptime')
    assert_match(/\d+:\d+:\d+:\d+/, result)
  end
  
  def test_user_exists
    result = @server.call('system.user_exists?', 'bogus-username')
    assert !result
  end
  
  def test_user_exists_with_invalid_arguments
    result = @server.call('system.user_exists?', { :hash => 'yeah' })
    assert !result
  end
  
  def test_user_exists
    result = @server.call('system.group_exists?', 'bogus-group')
    assert !result
  end
end