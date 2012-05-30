require 'readme_tester/commands'

class ReadmeTester
  class Evaluator
    attr_reader :to_evaluate

    def initialize(to_evaluate)
      @to_evaluate = to_evaluate
    end

    def self.visible_commands
      [:test]
    end

    def self.invisible_commands
      []
    end

    def tests_pass?
      evaluate
      !@failing_test
    end

    def failure_message
      @failing_test.failure_message
    end

    def tests
      @tests ||= []
    end

    def test(name, options={}, &block)
      test = Commands::Test.new(name, options.merge(code: block.call))
      strategy = Commands::Test::Strategy.for(test.strategy).new(test.code)
      @failing_test = strategy unless strategy.pass?
      tests << test
    end

    def known_commands
      %w[test]
    end

    def document
      evaluate
      @document ||= ''
    end

    def evaluate
      return if @evaluated
      @evaluated = true
      instance_eval to_evaluate
    end
  end
end
