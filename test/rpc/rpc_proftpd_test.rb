require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class XmlRpc_ProftpdBackendTest < Test::Unit::TestCase
  def setup
    @server = $server
  end
  
  def test_present?
    result = call_proftpd('present?')
    assert_equal true, result
  end

  def test_name
    result = call_proftpd('name')
    assert_equal result, 'Backends::Proftpd'    
  end

  def test_ftp_account_exists_with_invalid_user
    result = call_proftpd('ftp_account_exists?', 'nonexistent')
    assert_equal false, result
  end

  def test_ftp_account_exists_with_valid_user
    result = call_proftpd('ftp_account_exists?', 'blueberry.cz')
    assert_equal true, result
  end

  def test_create_ftp_account_with_no_attributes
    result = call_proftpd('create_ftp_account', {})
    assert_equal false, result
  end

  def test_create_ftp_account
    attributes = {:username => 'johnnyquid', :password => 'password123', :domain => 'quid.cz', :subdomain => 'www'}
    result = call_proftpd('create_ftp_account', attributes)
    assert_equal true, result
  end

  def test_destroy_ftp_account_with_invalid_username
    result = call_proftpd('destroy_ftp_account', 'nonexistent')
    assert_equal false, result
  end
  
  def test_destroy_ftp_account
    result = call_proftpd('destroy_ftp_account', 'blueberry.cz')
    assert_equal true, result
  end
  
  protected

  def call_proftpd(method, *args)
    arguments = ["proftpd.#{method}"]
    arguments << args unless args.empty?
    @server.call(*arguments)
  end
end
