require 'rspec/core/formatters/base_formatter'

class MountainBerryFields
  module Commands
    class Test
      module Strategy
        class RSpec
          class Formatter < ::RSpec::Core::Formatters::BaseFormatter
            def example_failed(example)
              require 'json'
              print JSON.dump 'full_description' => example.full_description,
                              'message'          => example.exception.message,
                              'backtrace'        => format_backtrace(example.exception.backtrace, example)
            end
          end
        end
      end
    end
  end
end
