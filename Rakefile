#!/usr/bin/env rake
require 'bundler/setup'

desc 'Run specs'
task :spec do
  sh 'rspec'
end

task rspec_must_be_100_percent: :spec do
  require 'simplecov'
  percent = SimpleCov.result.covered_percent
  unless percent == 100
    SimpleCov.result.format!
    fail "\e[31mYo, dawg some of your shit isn't getting tested, only %0.2f%%\e[0m" % percent
  end
end


desc 'Run non-work-in-progress cukes'
task :cuke do
  sh 'cucumber --tag ~@wip'
end

namespace :cuke do
  desc 'Run work-in-progress cukes'
  task :wip do
    sh 'cucumber --tag @wip'
  end
end

desc 'Generate readme'
task :readme do
  sh 'bin/mountain_berry_fields Readme.md.mountain_berry_fields'
end

task default: [:rspec_must_be_100_percent, :cuke, :readme]
