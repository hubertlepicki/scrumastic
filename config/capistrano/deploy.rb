$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2'        # Or whatever env you want it to run in.

set :application, "scrumastic"
set :repository, "http://github.com/hubertlepicki/scrumastic.git"
set :scm, "git"
set :checkout, "export"
set :scm_verbose, true
#set :deploy_via, :remote_cache
set :server_name, "scrumastic.s.amberbit.com"
set :user, 'scrumastic'
set :runner, 'scrumastic'
set :base_path, "/home/scrumastic"
set :deploy_to, "/home/scrumastic/app"
set :use_sudo, false
set :git_enable_submodules,1

role(:web) { server_name }
role(:app) { server_name }
role(:db, :primary => true) { server_name }

ssh_options[:paranoid] = false
default_run_options[:pty] = true

#after "deploy:setup", "init:set_permissions"
#after "deploy:setup", "init:database_yml"
#after "deploy:restart", "config:restart_daemons"
after "deploy:update_code", "deploy:cleanup"

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, 'vendor', 'bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
 
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install vendor/bundle"
  end
end
 
after 'deploy:update_code', 'bundler:bundle_new_release'

# Overrides for Phusion Passenger
namespace :deploy do
  desc "Restarting passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

# Configuration Tasks
namespace :config do
  desc "copy shared configurations to current"
  task :copy_shared_configurations, :roles => [:app] do
    %w[mongoid.yml application/config.yml].each do |f|
      run "rm -rf #{release_path}/config/#{f}"
      run "ln -nsf #{shared_path}/config/#{f} #{release_path}/config/#{f}"
    end
  end
end

after "deploy:symlink", "config:copy_shared_configurations"

require 'cap_recipes/tasks/passenger'

