require 'deject'

require 'readme_tester/version'
require 'readme_tester/evaluator'
require 'readme_tester/parser'

def ReadmeTester(argv)
  ReadmeTester.new(argv).execute
end

class ReadmeTester
  Deject self, :interaction
  dependency(:evaluator_class) { Evaluator }
  dependency(:parser_class)    { Parser }
  dependency(:file_class)      { File }

  SUCCESS_STATUS = 0
  FAILURE_STATUS = 1

  def initialize(argv)
    self.argv = argv
  end

  def execute
    missing_input_file || invalid_filename || nonexistent_file || execute!
  end

  def evaluator
    @evaluator ||= evaluator_class.new
  end

  def parser
    @parser ||= parser_class.new file_class.read(filename), evaluator
  end

private

  def missing_input_file
    return if filename
    interaction.declare_failure 'Please provide an input file'
    FAILURE_STATUS
  end

  def invalid_filename
    return if filename =~ suffix_regex
    interaction.declare_failure "#{filename.inspect} does not end in .testable_readme"
    FAILURE_STATUS
  end

  def nonexistent_file
    return if file_class.exist? filename
    interaction.declare_failure "#{File.expand_path(filename).inspect} does not exist."
    FAILURE_STATUS
  end

  def execute!
    begin
      parser.parse
      if evaluator.tests_pass?
        file_class.write output_filename_for(filename), parser.parsed
        SUCCESS_STATUS
      else
        interaction.declare_failure evaluator.failure_message
        FAILURE_STATUS
      end
    rescue StandardError
      interaction.declare_failure "#{$!.class} #{$!.message}"
      FAILURE_STATUS
    end
  end

  def filename
    argv.first
  end

  def output_filename_for(filename)
    filename.sub suffix_regex, ''
  end

  def suffix_regex
    /\.testable_readme$/
  end

  attr_accessor :argv
end
