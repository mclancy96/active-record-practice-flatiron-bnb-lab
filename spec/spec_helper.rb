require 'rspec'

ENV['RACK_ENV'] = 'test'

require_relative '../config/environment'

# Set up test database
RSpec.configure do |config|
  config.before(:each) do
    # Clean up database before each test in the correct order due to foreign key constraints
    ActiveRecord::Base.connection.execute("DELETE FROM reviews")
    ActiveRecord::Base.connection.execute("DELETE FROM reservations")
    ActiveRecord::Base.connection.execute("DELETE FROM listings")
    ActiveRecord::Base.connection.execute("DELETE FROM neighborhoods")
    ActiveRecord::Base.connection.execute("DELETE FROM cities")
    ActiveRecord::Base.connection.execute("DELETE FROM users")
  end
end
