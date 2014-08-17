class MountainBerryFields
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
        @registered.fetch name.to_s do
          raise NameError, "#{name.inspect} is not a registered strategy, should have been in #{@registered.keys.inspect}"
        end
      end

      def self.register(name, strategy)
        @registered[name.to_s] = strategy
      end

      def self.unregister(name)
        @registered.delete name.to_s
      end

      def self.registered?(name)
        @registered.has_key? name.to_s
      end

      attr_reader :code_to_test

      def initialize(code_to_test)
        @code_to_test = code_to_test.to_s
      end

      def pass?
        raise "unimplemented"
      end

      def failure_message
        raise "unimplemented"
      end
    end
  end
end
