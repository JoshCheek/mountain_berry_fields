require 'open3'

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

    # checks syntax of a code example
    class SyntaxChecker
      def initialize(code_to_test)
        @code_to_test = code_to_test
      end

      def valid?
        return @valid if defined? @valid
        out, err, status = Open3.capture3 'ruby -c', stdin_data: @code_to_test
        @stderr = err
        @valid = status.exitstatus.zero?
      end

      def invalid_message
        valid?
        "#{@stderr.chomp}\n\noriginal file:\n#@code_to_test"
      end
    end

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


    require 'json'
    require 'tmpdir'
    require 'mountain_berry_fields/commands/test/strategy/rspec/formatter'
    class RSpec
      Deject self
      dependency(:file_class)           { File          }
      dependency(:dir_class)            { Dir           }
      dependency(:open3_class)          { Open3         }
      dependency(:syntax_checker_class) { SyntaxChecker }

      def syntax_checker
        @syntax_checker ||= syntax_checker_class.new code_to_test
      end

      Strategy.register :rspec, self

      include Strategy

      def pass?
        @passed ||= syntax_checker.valid? && begin
          dir_class.mktmpdir 'mountain_berry_fields_rspec' do |dir|
            @tempdir_name = dir
            file_class.write "#{dir}/spec.rb", @code_to_test
            @output, @error, status = open3_class.capture3 "rspec '#{dir}/spec.rb' " \
                                                           "-r '#{formatter_filename}' " \
                                                           "-f MountainBerryFields::Commands::Test::Strategy::RSpec::Formatter " \
                                                           "--fail-fast"
            status.success?
          end
        end
        @passed
      end

      def syntax_error_message
        return if syntax_checker.valid?
        syntax_checker.invalid_message
      end

      def failure_message
        syntax_error_message ||
          "#{spec_failure_description.chomp}:\n"      \
          "  #{spec_failure_message.chomp}\n"         \
          "\n"                                        \
          "backtrace:\n"                              \
          "  #{spec_failure_backtrace.join "\n  "}\n"
      end

      private

      def spec_failure_description
        result['full_description']
      end

      def spec_failure_message
        result['message']
      end

      def spec_failure_backtrace
        result['backtrace'].map { |line| line.gsub @tempdir_name, '' }
      end

      def result
        @result ||= JSON.parse @output
      end

      def formatter_filename
        File.expand_path "../test/strategy/rspec/formatter.rb", __FILE__
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


    require 'rcodetools/xmpfilter'
    class MagicComments
      Strategy.register :magic_comments, self
      include Strategy

      Deject self
      dependency(:syntax_checker_class) { SyntaxChecker }

      def syntax_checker
        @syntax_checker ||= syntax_checker_class.new code_to_test
      end

      def result
        @result ||= Rcodetools::XMPFilter.run(
          code_to_test,
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

      def syntax_error_message
        return if syntax_checker.valid?
        syntax_checker.invalid_message
      end

      def pass?
        each_line_pair do |expected_line, actual_line|
          return false unless normalize(expected_line) == normalize(actual_line)
        end
        true
      end

      def failure_message
        syntax_error_message ||
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
