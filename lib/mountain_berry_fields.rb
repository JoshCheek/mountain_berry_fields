require 'deject'

require 'mountain_berry_fields/version'
require 'mountain_berry_fields/evaluator'
require 'mountain_berry_fields/parser'

# Ties everything together. It gets the file, passes it to the parser,
# passes the result to the evaluator, and writes the file. If anything
# goes wrong along the way, it declares the failure to the interaction
class MountainBerryFields
  Deject self, :interaction
  dependency(:evaluator_class) { Evaluator }
  dependency(:parser_class)    { Parser }
  dependency(:file_class)      { File }

  def initialize(argv)
    self.argv = argv
  end

  def execute
    return false if missing_input_file? || invalid_filename? || nonexistent_file?
    execute!
  end

  def evaluator
    @evaluator ||= evaluator_class.new parser.parse
  end

  def parser
    @parser ||= parser_class.new  file_class.read(filename),
                                  visible:   evaluator_class.visible_commands,
                                  invisible: evaluator_class.invisible_commands
  end

private

  def missing_input_file?
    return if filename
    interaction.declare_failure 'Please provide an input file'
    true
  end

  def invalid_filename?
    return if filename =~ filename_regex
    interaction.declare_failure "#{filename.inspect} does not match #{filename_regex.inspect}"
    true
  end

  def nonexistent_file?
    return if file_class.exist? filename
    interaction.declare_failure "#{File.expand_path(filename).inspect} does not exist."
    true
  end

  def execute!
    begin
      if evaluator.tests_pass?
        file_class.write output_filename_for(filename), evaluator.document
        true
      else
        interaction.declare_failure "FAILURE: #{evaluator.failure_name}\n#{evaluator.failure_message}"
        false
      end
    rescue StandardError
      interaction.declare_failure "#{$!.class} #{$!.message}"
      false
    end
  end

  def filename
    argv.first
  end

  def output_filename_for(filename)
    filename.sub filename_regex, ''
  end

  def filename_regex
    /\.mountain_berry_fields\b/
  end

  attr_accessor :argv
end
