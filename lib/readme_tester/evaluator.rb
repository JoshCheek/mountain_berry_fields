require 'readme_tester/commands'

class ReadmeTester
  class Evaluator
    attr_reader :to_evaluate

    def initialize(to_evaluate)
      @to_evaluate = to_evaluate
    end

    def tests_pass?
      evaluate
      strategies = tests.map { |test| Commands::Test::Strategy.for(test.strategy).new(test.code) }
      @failing_test = strategies.find { |s| !s.pass? }
      !@failing_test
    end

    def failure_message
      @failing_test.failure_message
    end

    def tests
      @tests ||= []
    end

    def add_test(name, options={})
      tests << Commands::Test.new(name, options)
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
