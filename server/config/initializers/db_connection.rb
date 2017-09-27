#Making a database connection

database_connection = Rails.application.config_for(:database)

DB = Sequel.connect(database_connection)

DB.loggers << Logger.new($stdout) if Rails.env.development?

Sequel.extension :migration
Sequel::Model.plugin :touch

# Global default
Sequel::Model.strict_param_setting = false
