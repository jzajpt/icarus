require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class XmlRpc_MysqlBackendTest < Test::Unit::TestCase
  def setup
    @server = $server
  end
  
  def test_present?
    result = @server.call('mysql.present?')
    assert result
  end
  
  def test_name
    result = @server.call('mysql.name')
    assert_equal result, 'Backends::Mysql'    
  end
  
  def test_get_all_databases
    result = @server.call('mysql.get_all_databases')
    assert_kind_of Array, result
    assert_not_equal result.size, 0
  end
  
  def test_user_exists_with_invalid_user
    result = @server.call('mysql.user_exists?', 'nonexistent')
    assert !result
  end
  
  def test_user_exists_with_invalid_user_and_host
    result = @server.call('mysql.user_exists?', 'nonexistent', 'nonexistenthost')
    assert !result
  end

  def test_user_exists_with_valid_user
    result = @server.call('mysql.user_exists?', 'root')
    assert result
  end
  
  def test_user_exists_with_valid_user_and_host
    result = @server.call('mysql.user_exists?', 'root', 'localhost')
    assert result
  end
  
  def test_database_exists_with_invalid_database
    result = @server.call('mysql.database_exists?', 'nonexistent')
    assert !result
  end
  
  def test_database_exists_with_valid_database
    result = @server.call('mysql.database_exists?', 'mysql')
    assert result
  end
end
