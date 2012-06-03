require 'mountain_berry_fields/commands'

class MountainBerryFields

  # This class evaluates a block of code that was emitted from the parser.
  # It has a document that the evalutable code can append to.
  # It implements the visible and invisible methods (see the parser for more on these)
  # that MountainBerryFields supports.
  #
  # It also evaluates tests, and tracks whether they pass or fail (currently only tracking the last failure)
  class Evaluator
    attr_reader :to_evaluate

    def initialize(to_evaluate)
      @to_evaluate = to_evaluate
    end

    def self.visible_commands
      [:test]
    end

    def self.invisible_commands
      [:setup]
    end

    def setup
      setup_code << yield
    end

    def setup_code
      @setup_code ||= ''
    end

    def test(name, options={}, &block)
      code = setup_code + block.call.to_s
      test = Commands::Test.new(name, options.merge(code: code))
      strategy = Commands::Test::Strategy.for(test.strategy).new(test.code)
      unless strategy.pass?
        @failing_strategy = strategy
        @failing_test     = test
      end
      tests << test
    end

    def tests_pass?
      evaluate
      !@failing_test
    end

    def failure_name
      @failing_test.name
    end

    def failure_message
      @failing_strategy.failure_message
    end

    def tests
      @tests ||= []
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
