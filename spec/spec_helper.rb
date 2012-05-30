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

  class Evaluator
    Surrogate.endow self
    define(:initialize)      { @document = '' }
    define(:tests_pass?)     { true }
    define(:known_commands)  { ['test'] }
    define(:add_test)        { |test, &block| block.call }
    define(:failure_message) { 'some failure message' }
    define(:document)

    def inspect
      '#<MOCK EVALUATOR>'
    end
  end

  class Parser
    Surrogate.endow self
    define(:initialize) {}
    define(:parse) { 'some body' }
    define(:parsed) { parse }

    def inspect
      '#<MOCK PARSER>'
    end
  end
end

ReadmeTester.override(:file_class)      { Mock::File.clone }
ReadmeTester.override(:interaction)     { Mock::Interaction.new }
ReadmeTester.override(:evaluator_class) { Mock::Evaluator.clone }
ReadmeTester.override(:parser_class)    { Mock::Parser.clone }

ReadmeTester::CommandLineInteraction.override(:stderr) { StringIO.new }
