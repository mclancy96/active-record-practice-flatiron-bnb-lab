require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'] || 'development')

require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'] || 'development')

# Set up ActiveRecord logger
require 'logger'
ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['RACK_ENV'] == 'development'
ActiveRecord::Base.logger = nil if ENV['RACK_ENV'] == 'test'

# Connect to database
database_config = YAML.load_file('config/database.yml', aliases: true)
environment = ENV['RACK_ENV'] || 'development'
ActiveRecord::Base.establish_connection(database_config[environment])

# Require all models
Dir[File.join(File.dirname(__FILE__), '..', 'app', 'models', '*.rb')].each { |file| require file }

# Require all models
require_relative '../app/models/user'
require_relative '../app/models/city'
require_relative '../app/models/neighborhood'
require_relative '../app/models/listing'
require_relative '../app/models/reservation'
require_relative '../app/models/review'
