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

Deject.register(:stdin)      { StringIO.new }
Deject.register(:stdout)     { StringIO.new }
Deject.register(:stderr)     { StringIO.new }
Deject.register(:file_class) { Mock::File.clone }
