require 'open3'

class MountainBerryFields
  class Test
    # checks syntax of a code example
    class Test::RubySyntaxChecker
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
  end
end
