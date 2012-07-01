require 'rcodetools/xmpfilter'

class MountainBerryFields
  class Test


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
