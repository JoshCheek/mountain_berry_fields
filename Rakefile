#!/usr/bin/env rake
require 'bundler/gem_tasks'


require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new :rspec
task default: :rspec


require 'cucumber/rake/task'
default_cucumber_opts = "features --format pretty --tags ~@not-implemented"
Cucumber::Rake::Task.new(:cucumber)      { |t| t.cucumber_opts = default_cucumber_opts + " --tags ~@wip" }
Cucumber::Rake::Task.new('cucumber:wip') { |t| t.cucumber_opts = default_cucumber_opts + " --tags @wip" }

task default: :cucumber
