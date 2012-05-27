# -*- encoding: utf-8 -*-
require File.expand_path('../lib/readme_tester/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Josh Cheek"]
  gem.email         = ["josh.cheek@gmail.com"]
  gem.description   = %q{Test code samples in readme file}
  gem.summary       = %q{Test code samples in readme file}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "readme_tester"
  gem.require_paths = ["lib"]
  gem.version       = ReadmeTester::VERSION

  gem.add_development_dependency 'deject',    '~> 0.2.2'
  gem.add_development_dependency 'surrogate', '~> 0.4.2'
  gem.add_development_dependency 'rspec',     '~> 2.10.0'
  gem.add_development_dependency 'cucumber',  '~> 1.2.0'
end
