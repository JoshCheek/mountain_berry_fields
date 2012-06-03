require 'simplecov'

require 'mountain_berry_fields'
require 'mountain_berry_fields/command_line_interaction'

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
    Surrogate.endow self do
      define(:visible_commands)   { [:visible] }
      define(:invisible_commands) { [:invisible] }
    end

    define(:initialize)      { @document = '' }
    define(:tests_pass?)     { true }
    define(:test)            { |test, &block| block.call }
    define(:failure_message) { 'some failure message' }
    define(:failure_name)    { 'failing test name' }
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

MountainBerryFields.override(:file_class)      { Mock::File.clone }
MountainBerryFields.override(:interaction)     { Mock::Interaction.new }
MountainBerryFields.override(:evaluator_class) { Mock::Evaluator.clone }
MountainBerryFields.override(:parser_class)    { Mock::Parser.clone }

MountainBerryFields::CommandLineInteraction.override(:stderr) { StringIO.new }
