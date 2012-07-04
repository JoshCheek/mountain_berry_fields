# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mountain_berry_fields/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Josh Cheek"]
  gem.email         = ["josh.cheek@gmail.com"]
  gem.description   = %q{Test code samples embedded in files like readmes}
  gem.summary       = %q{Test code samples embedded in files like readmes}
  gem.homepage      = "https://github.com/JoshCheek/mountain_berry_fields"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mountain_berry_fields"
  gem.require_paths = ["lib"]
  gem.version       = MountainBerryFields::VERSION

  gem.add_runtime_dependency 'erubis',                                   '= 2.7.0'
  gem.add_runtime_dependency 'deject',                                   '~> 0.2.2'

  gem.add_development_dependency 'mountain_berry_fields-magic_comments', '~> 1.0.0'
  gem.add_development_dependency 'mountain_berry_fields-rspec',          '~> 1.0.0'
  gem.add_development_dependency 'surrogate',                            '~> 0.5.1'
  gem.add_development_dependency 'rspec',                                '~> 2.10.0'
  gem.add_development_dependency 'cucumber',                             '~> 1.2.0'
  gem.add_development_dependency 'simplecov',                            '~> 0.6.4'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'pry'
end
