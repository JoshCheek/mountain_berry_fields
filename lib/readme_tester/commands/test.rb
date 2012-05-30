module ReadmeTester::Commands
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
    module Strategy
      @registered = {}

      def self.for(name)
        @registered.fetch name
      end

      def self.register(name, strategy)
        @registered[name] = strategy
      end

      attr_accessor :code_to_test

      def initialize(code_to_test)
        self.code_to_test = code_to_test
      end

      def pass?
        raise "unimplemented"
      end

      def failure_message
        raise "unimplemented"
      end
    end


    class AlwaysPass
      Strategy.register :always_pass, self

      include Strategy

      def pass?
        eval code_to_test || ''
      ensure
        return true
      end
    end


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
