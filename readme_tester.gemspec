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
end
