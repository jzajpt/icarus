require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class XmlRpc_MysqlBackendTest < Test::Unit::TestCase
  def setup
    @server = $server
  end
  
  def test_present?
    result = call_mysql('present?')
    assert_equal true, result
  end
  
  def test_name
    result = call_mysql('name')
    assert_equal result, 'Backends::Mysql'    
  end
  
  def test_get_all_databases
    result = call_mysql('get_all_databases')
    assert_kind_of Array, result
    assert_not_equal result.size, 0
  end
  
  def test_user_exists_with_invalid_user
    result = call_mysql('user_exists?', 'nonexistent')
    assert_equal false, result
  end
  
  def test_user_exists_with_invalid_user_and_host
    result = call_mysql('user_exists?', 'nonexistent', 'nonexistenthost')
    assert_equal false, result
  end

  def test_user_exists_with_valid_user
    result = call_mysql('user_exists?', 'root')
    assert_equal true, result
  end
  
  def test_user_exists_with_valid_user_and_host
    result = call_mysql('user_exists?', 'root', 'localhost')
    assert_equal true, result
  end
  
  def test_database_exists_with_invalid_database
    result = call_mysql('database_exists?', 'nonexistent')
    assert_equal false, result
  end
  
  def test_database_exists_with_valid_database
    result = call_mysql('database_exists?', 'mysql')
    assert_equal true, result
  end
  
  protected
  
  def call_mysql(method, *args)
    arguments = ["mysql.#{method}"]
    arguments << args unless args.empty?
    @server.call(*arguments)
  end
end
