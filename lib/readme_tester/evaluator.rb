require 'erubis'
require 'readme_tester/commands'
require 'readme_tester/parser'

# This code should be considered volatile
# It may change such that not all commands receive code
# It may change such to allow for arbitrary addition of commands (for plugins)
class ReadmeTester
  YoDawgThisIsntReallyERB = Class.new StandardError
  UnbalancedCommands      = Class.new StandardError

  class Evaluator
    def initialize(to_evaluate)
      @to_evaluate = to_evaluate
    end

    def tests_pass?
      true
    end

    def result
      ensure_interpreted
      @result
    end

    def ensure_interpreted
      return if @already_interpreted
      @already_interpreted = true
      @result = Parser.new(@to_evaluate, self).parse
    end

    def tests
      ensure_interpreted
      @tests ||= []
    end

    def add_test(name, options={})
      tests << Commands::Test.new(name, options)
    end

    def known_commands
      %w[test]
    end

  private

    attr_accessor :to_evaluate
  end
end
