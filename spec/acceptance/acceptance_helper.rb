require File.dirname(__FILE__) + "/../spec_helper"
require "steak"
require 'capybara/rails'

Capybara.default_driver = :selenium

RSpec.configure do |config|
  config.include Capybara
end


RSpec.configuration.include Capybara, :type => :acceptance

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

def sign_in_as(name)
  visit "/users/sign_in"
  fill_in "Email", with: "#{name.downcase}@example.com"
  fill_in "Password", with: "asdf1234"
  within(:css, "form.user_new") do
    click_button "Sign in"
  end
end


def create_standard_users
  create_users "Hubert", "Wojtek", "Deborah", "Alex", "Lukasz"
end

def create_users *list
  users = {}
  list.each do |name|
    u = User.create!(valid_user_attributes(name))
    u.update_attributes :confirmation_token => nil,
                        :confirmed_at => Time.zone.now.utc
    users[name.downcase.to_sym] = u
  end
  users
end

