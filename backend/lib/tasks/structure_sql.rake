# pg_dump 17+ emits SET transaction_timeout. The app database is Postgres 16,
# which rejects that parameter and then fails to load db/structure.sql.
Rake::Task["db:schema:dump"].enhance do
  path = Rails.root.join("db/structure.sql")
  next unless path.file?

  sql = path.read
  stripped = sql.gsub(/^SET transaction_timeout = 0;\n/, "")
  path.write(stripped) unless stripped == sql
end
