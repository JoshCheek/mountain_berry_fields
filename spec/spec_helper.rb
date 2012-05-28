require 'simplecov'

require 'readme_tester'
require 'readme_tester/command_line_interaction'

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

  class Interaction
    Surrogate.endow self
    define(:declare_failure) { }
  end
end
ReadmeTester.override(:interaction) { Mock::Interaction.new }
ReadmeTester.override(:file_class)  { Mock::File.clone }

ReadmeTester::CommandLineInteraction.override(:stderr) { StringIO.new }
