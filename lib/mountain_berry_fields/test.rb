require 'mountain_berry_fields/test/strategy'
require 'mountain_berry_fields/test/ruby_syntax_checker'

Gem.find_files("mountain_berry_fields/autoloaded_strategies/*").each { |path| require path }

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
end
