# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amberbit-config}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wojciech Piekutowski", "Hubert Lepicki"]
  s.date = %q{2010-08-22}
  s.description = %q{Reads YAML files with configuration. Allows you to specify default configuration file you can store in repository and overwrite it with custom configuration file for each application instance and environment.}
  s.email = %q{hubert.lepicki@amberbit.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "README",
     "Rakefile",
     "VERSION",
     "amberbit-config.gemspec",
     "init.rb",
     "install.rb",
     "lib/amber_bit_app_config.rb",
     "lib/amberbit-config.rb",
     "lib/hash_struct.rb",
     "rails/init.rb",
     "spec/library_spec.rb",
     "spec/plugin_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/testapp/README",
     "spec/testapp/Rakefile",
     "spec/testapp/app/controllers/application_controller.rb",
     "spec/testapp/app/helpers/application_helper.rb",
     "spec/testapp/config/application/config.yml",
     "spec/testapp/config/application/default.yml",
     "spec/testapp/config/boot.rb",
     "spec/testapp/config/environment.rb",
     "spec/testapp/config/environments/development.rb",
     "spec/testapp/config/environments/production.rb",
     "spec/testapp/config/environments/test.rb",
     "spec/testapp/config/initializers/backtrace_silencers.rb",
     "spec/testapp/config/initializers/inflections.rb",
     "spec/testapp/config/initializers/mime_types.rb",
     "spec/testapp/config/initializers/new_rails_defaults.rb",
     "spec/testapp/config/initializers/session_store.rb",
     "spec/testapp/config/locales/en.yml",
     "spec/testapp/config/routes.rb",
     "spec/testapp/db/test.sqlite3",
     "spec/testapp/doc/README_FOR_APP",
     "spec/testapp/log/development.log",
     "spec/testapp/log/production.log",
     "spec/testapp/log/server.log",
     "spec/testapp/log/test.log",
     "spec/testapp/public/404.html",
     "spec/testapp/public/422.html",
     "spec/testapp/public/500.html",
     "spec/testapp/public/favicon.ico",
     "spec/testapp/public/images/rails.png",
     "spec/testapp/public/index.html",
     "spec/testapp/public/javascripts/application.js",
     "spec/testapp/public/javascripts/controls.js",
     "spec/testapp/public/javascripts/dragdrop.js",
     "spec/testapp/public/javascripts/effects.js",
     "spec/testapp/public/javascripts/prototype.js",
     "spec/testapp/public/robots.txt",
     "spec/testapp/script/about",
     "spec/testapp/script/console",
     "spec/testapp/script/dbconsole",
     "spec/testapp/script/destroy",
     "spec/testapp/script/generate",
     "spec/testapp/script/performance/benchmarker",
     "spec/testapp/script/performance/profiler",
     "spec/testapp/script/plugin",
     "spec/testapp/script/runner",
     "spec/testapp/script/server",
     "spec/testapp/test/performance/browsing_test.rb",
     "spec/testapp/test/test_helper.rb",
     "tasks/amberbit_app_config_tasks.rake",
     "uninstall.rb"
  ]
  s.homepage = %q{http://github.com/amberbit/amberbit-config}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Yet Another AppConfig for Rails but not only}
  s.test_files = [
    "spec/testapp/config/boot.rb",
     "spec/testapp/config/environment.rb",
     "spec/testapp/config/environments/development.rb",
     "spec/testapp/config/environments/production.rb",
     "spec/testapp/config/environments/test.rb",
     "spec/testapp/config/initializers/backtrace_silencers.rb",
     "spec/testapp/config/initializers/mime_types.rb",
     "spec/testapp/config/initializers/new_rails_defaults.rb",
     "spec/testapp/config/initializers/session_store.rb",
     "spec/testapp/config/initializers/inflections.rb",
     "spec/testapp/config/routes.rb",
     "spec/testapp/test/test_helper.rb",
     "spec/testapp/test/performance/browsing_test.rb",
     "spec/testapp/app/controllers/application_controller.rb",
     "spec/testapp/app/helpers/application_helper.rb",
     "spec/library_spec.rb",
     "spec/plugin_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

