require 'open3'


class MountainBerryFields

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

  # You want to run tests, amirite? So you need something that runs them.
  # Right now that's called a strategy (expect that to change). Strategies
  # take the code to test as a string, and then test them and return if they
  # pass or fail.
  #
  # Strategies should probably be registered so that the evaluator can find them.
  module Test::Strategy
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

require 'mountain_berry_fields/test/always_fail'
require 'mountain_berry_fields/test/always_pass'
Gem.find_files("mountain_berry_fields/test/*").each { |path| require path }
