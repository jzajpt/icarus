module SqlHelper
  def process_sql_file(filename)
    File.open(filename, 'r') do |file|
      sql_queries = file.read.split(';')
      sql_queries.each do |query|
        next if query.strip.empty?
        MysqlAdapter.execute query
      end
    end
  end
end