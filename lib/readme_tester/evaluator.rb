require 'erubis'
require 'readme_tester/commands'
require 'readme_tester/parser'

class ReadmeTester
  class Evaluator
    def tests_pass?
      true
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
  end
end
