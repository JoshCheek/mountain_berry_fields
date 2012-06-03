module MountainBerryFields::Commands

  # Data structure to store the shit passed to the test method
  class Test
    attr_accessor :name, :options

    def initialize(name, options)
      self.name, self.options = name, options
    end

    def strategy
      options[:with]
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
        @registered.fetch name do
          raise NameError, "#{name.inspect} is not a registered strategy, should have been in #{@registered.keys.inspect}"
        end
      end

      def self.register(name, strategy)
        @registered[name] = strategy
      end

      def self.unregister(name)
        @registered.delete name
      end

      def self.registered?(name)
        @registered.has_key? name
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


      # Ask it if it passes
    #
    # (it does)
    class AlwaysPass
      Strategy.register :always_pass, self

      include Strategy

      def pass?
        eval code_to_test
      ensure
        return true
      end
    end


    # Red. Red. Refactor anyway, cuz fuck it.
    class AlwaysFail
      Strategy.register :always_fail, self

      include Strategy

      def pass?
        eval code_to_test
      ensure
        return false
      end

      def failure_message
        "THIS STRATEGY ALWAYS FAILS"
      end
    end


    class MagicComments
      Strategy.register :magic_comments, self

      include Strategy

      def result
        @result ||= begin
                      require 'rcodetools/xmpfilter'
                      Rcodetools::XMPFilter.run(code_to_test,
                        :interpreter => "ruby",
                        :options => [],
                        :min_codeline_size => 50,
                        :libs => [],
                        :evals => [],
                        :include_paths => [],
                        :dump => nil,
                        :wd => nil,
                        :warnings => false,
                        :use_parentheses => true,
                        :column => nil,
                        :output_stdout => true,
                        :test_script => nil,
                        :test_method => nil,
                        :detect_rct_fork => false,
                        :use_rbtest => false,
                        :detect_rbtest => false,
                        :execute_ruby_tmpfile => false
                      ).join
                    end
      end

      def pass?
        each_line_pair do |expected_line, actual_line|
          return false unless normalize(expected_line) == normalize(actual_line)
        end
        true
      end

      def failure_message
        each_line_pair do |expected_line, actual_line|
          next if lines_match? expected_line, actual_line
          return "Output had extra line: #{actual_line}\n" unless expected_line
          return "Input had extra line: #{expected_line}\n" unless actual_line
          return "Expected: #{expected_line.gsub /^\s+/, ''}\nActual:   #{actual_line.lstrip.gsub /^\s+/, ''}\n" if expected_line != actual_line
        end
      end

      def lines_match?(line1, line2)
        normalize(line1) == normalize(line2)
      end

      def normalize(line)
        return unless line
        line.gsub!(/(#<\w+?):(0x[0-9a-f]+)/, '\1')         # replace anonymous instances
        line.gsub!(/#<(#<Class>):(0x[0-9a-f]+)>/, '#<\1>') # replace anonymous instances of anonymous classes end
        line
      end

      def each_line_pair
        result_lines = lines result
        code_to_test_lines = lines code_to_test

        while result_lines.any? || code_to_test_lines.any?
          yield chomp_or_nil(code_to_test_lines.shift), chomp_or_nil(result_lines.shift)
        end
      end

      def lines string
        string.lines.to_a
      end

      def chomp_or_nil value
        value && value.chomp
      end
    end
  end
end
