module MysqlHelper
  # Creates user with specified parameters.
  def create_user(user, host, password)
    MysqlAdapter.execute "CREATE USER #{user}@'#{host}' IDENTIFIED BY '#{password}'"
  end

  # Creates user with random user name. Returns created user name.
  def create_random_user(host = 'localhost')
    name = "icarususer#{rand(10000)}"
    create_user(name, host, 'password123')
    name
  end

  # Returns users password from mysql.user table.
  def get_user_password(username, host = 'localhost')
    attrs = MysqlAdapter.select_one "SELECT Password from mysql.user WHERE User = '#{@username}' and Host = '#{host}'"
    attrs['Password']
  end

  # Drops given user.
  def drop_user(user, host)
    MysqlAdapter.execute "DROP USER #{user}@'#{host}'"
  end

  # Creates database with random name (icarustest<random-number>).
  def create_random_database
    name = "icarustest#{rand(10000)}"
    MysqlAdapter.execute "CREATE DATABASE #{name}"

    name
  end

  # Returns true if database with given name exists, otherwise false.
  def database_exists?(name)
    MysqlAdapter.select_one("SHOW DATABASES LIKE '#{name}'") != nil
  end

  # Drops given database.
  def drop_database(name)
    MysqlAdapter.execute "DROP DATABASE #{name}"
  end
end