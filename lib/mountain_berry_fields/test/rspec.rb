require 'open3'
require 'json'
require 'tmpdir'

class MountainBerryFields
  class Test

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
                                                           "-f MountainBerryFields::Test::RSpec::Formatter " \
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
        File.expand_path "../rspec_formatter.rb", __FILE__
      end
    end
  end
end


