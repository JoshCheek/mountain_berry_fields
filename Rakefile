#!/usr/bin/env rake
require 'bundler/gem_tasks'


require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new :rspec
task default: :rspec


require 'cucumber/rake/task'
Cucumber::Rake::Task.new :cucumber
task default: :cucumber
