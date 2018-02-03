require "bundler/gem_tasks"
require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'coveralls/rake/task'

Cucumber::Rake::Task.new(:features)
RSpec::Core::RakeTask.new(:spec)
Coveralls::RakeTask.new

task :default => [:spec, :features, 'coveralls:push']