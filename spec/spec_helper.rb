require 'simplecov'
require 'readme_tester'
require 'stringio'
require 'surrogate/rspec'

module Mock
  class File
    Surrogate.endow self do
      define(:exist?) { true }
      define(:write)  { true }
      define(:read)   { "file contents" }
    end
  end
end

ReadmeTester.override(:stdin)      { StringIO.new }
ReadmeTester.override(:stdout)     { StringIO.new }
ReadmeTester.override(:stderr)     { StringIO.new }
ReadmeTester.override(:file_class) { Mock::File.clone }
