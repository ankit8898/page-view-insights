#Making a database connection

DB = Sequel.connect(adapter: 'postgres', host: 'localhost', database: 'ankit')

Sequel.extension :migration, :core_extensions
