# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
ENV["CI_REPORTS"] = 'hudson/reports/spec/'
require 'ci/reporter/rake/rspec'

Scrumastic::Application.load_tasks
