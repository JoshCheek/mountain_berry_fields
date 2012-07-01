require 'rspec/core/formatters/base_formatter'
require 'json'

class MountainBerryFields
  class Test
    class RSpec
      class Formatter < ::RSpec::Core::Formatters::BaseFormatter
        def example_failed(example)
          print JSON.dump 'full_description' => example.full_description,
                          'message'          => example.exception.message,
                          'backtrace'        => format_backtrace(example.exception.backtrace, example)
        end
      end
    end
  end
end
