# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Hack around bug in Rspec when not using AR
module Rspec
  module Rails
    module TransactionalDatabaseSupport
      def active_record_configured?
        false
      end
    end
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = false
  config.before(:each) do
    Mongoid.database.collections.each {|col| begin col.drop; rescue; end }
  end

  config.after(:each) do
    Timecop.return
  end
end

def valid_project_attributes(title="Test project",
                             description="Some description",
                             owner=User.first(conditions: {nickname: "admin"}))
  { name: title, description: description, owner: owner }
end

def valid_user_attributes(name="admin")
  { nickname: name.downcase,
    name: name,
    password: "asdf1234",
    password_confirmantion: "asdf1234",
    email: "#{name.downcase}@example.com" }
end
