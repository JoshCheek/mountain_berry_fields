module ReadmeTester::Commands

  # Data structure to store the shit passed to the test method
  class Test
    attr_accessor :name, :options

    def initialize(name, options)
      self.name, self.options = name, options
    end

    def strategy
      options[:strategy]
    end

    def code
      options[:code]
    end
  end


  class Test

    # You want to run tests, amirite? So you need something that runs them.
    # Right now that's called a strategy (expect that to change). Strategies
    # take the code to test as a string, and then test them and return if they
    # pass or fail.
    #
    # Strategies should probably be registered so that the evaluator can find them.
    module Strategy
      @registered = {}

      def self.for(name)
        @registered.fetch name
      end

      def self.register(name, strategy)
        @registered[name] = strategy
      end

      attr_reader :code_to_test

      def initialize(code_to_test)
        @code_to_test = code_to_test
      end

      def pass?
        raise "unimplemented"
      end

      def failure_message
        raise "unimplemented"
      end
    end


    # Ask it if it passes
    #
    # (it does)
    class AlwaysPass
      Strategy.register :always_pass, self

      include Strategy

      def pass?
        eval code_to_test || ''
      ensure
        return true
      end
    end


    # Red. Red. Refactor anyway, cuz fuck it.
    class AlwaysFail
      Strategy.register :always_fail, self

      include Strategy

      def pass?
        eval code_to_test || ''
      ensure
        return false
      end

      def failure_message
        "THIS STRATEGY ALWAYS FAILS"
      end
    end
  end
end
