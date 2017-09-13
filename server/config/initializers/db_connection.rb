#Making a database connection

if Rails.env.test?
  database = 'ankit_test'
else
  database = 'ankit'
end

puts "Using database: #{database}"
DB = Sequel.connect(adapter: 'postgres', host: 'localhost', database: database)

Sequel.extension :migration
