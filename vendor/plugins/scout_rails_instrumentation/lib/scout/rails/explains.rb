class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def explain(sql)
    # TODO: find a better exception class
    raise NotImplementedError.new("This adapter is not supported. Only MySQL, PostgreSQL, SQLite, and SQLite3 are supported.")
  end
end

class ActiveRecord::ConnectionAdapters::MysqlAdapter
  def explain(sql)
    self.execute("EXPLAIN #{sql}").all_hashes
  end
end

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def explain(sql)
    self.execute("EXPLAIN #{sql}").flatten
  end
end

class ActiveRecord::ConnectionAdapters::SQLiteAdapter
  # This is inherited by SQLite3Adapter so it's not necessary to define it again.
  def explain(sql)
    self.execute("EXPLAIN QUERY PLAN #{sql}").map{|r| r["detail"] }
  end
end
