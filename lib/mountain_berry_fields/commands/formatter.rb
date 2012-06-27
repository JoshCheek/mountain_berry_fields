require 'rspec/core/formatters/base_formatter'

class CustomFormatter < RSpec::Core::Formatters::BaseFormatter
  def example_failed(example)
    puts example.full_description
    puts example.exception.message
  end
end
