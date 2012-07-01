require 'simplecov'

require 'mountain_berry_fields'
require 'mountain_berry_fields/command_line_interaction'

require 'stringio'
require 'surrogate/rspec'


RSpec::Matchers.define :pass do
  match { |matcher| matcher.pass? }
end

module Mock
  class SyntaxChecker
    Surrogate.endow self
    define(:initialize) { |syntax| }
    define(:valid?) { true }
    define(:invalid_message) { "shit ain't valid" }
  end

  class File
    Surrogate.endow self do
      define(:exist?) { true }
      define(:write)  { true }
      define(:read)   { "file contents" }
    end
  end

  class Dir
    Surrogate.endow self do
      define(:chdir)    { |dir,    &block| block.call }
      define(:mktmpdir) { |prefix, &block| block.call }
    end
  end

  module Process
    class ExitStatus
      Surrogate.endow self
      define(:success?) { true }
    end
  end

  class Open3
    Surrogate.endow self do
      define(:capture3) { |invocation| ["stdout", "stderr", @exitstatus||Process::ExitStatus.new] }
    end


    def self.exit_with_failure!
      @exitstatus = Process::ExitStatus.new.will_have_success? false
      self
    end

    def self.exit_with_success!
      @exitstatus = Process::ExitStatus.new.will_have_success? true
      self
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
MountainBerryFields.override(:dir_class)       { Mock::Dir.clone }
MountainBerryFields.override(:interaction)     { Mock::Interaction.new }
MountainBerryFields.override(:evaluator_class) { Mock::Evaluator.clone }
MountainBerryFields.override(:parser_class)    { Mock::Parser.clone }

MountainBerryFields::CommandLineInteraction.override(:stderr) { StringIO.new }
MountainBerryFields::Test::RSpec.override(:syntax_checker_class) { Mock::SyntaxChecker }
MountainBerryFields::Test::MagicComments.override(:syntax_checker_class) { Mock::SyntaxChecker }
