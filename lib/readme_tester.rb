require 'deject'
require 'readme_tester/version'

def ReadmeTester(argv)
  ReadmeTester.new(argv).execute
end

class ReadmeTester
  Deject self, :stdin, :stdout, :stderr, :file_class

  def initialize(argv)
    self.argv = argv
  end

  def execute
    missing_input_file || invalid_filename || nonexistent_file || execute!
  end

private

  def missing_input_file
    return if filename
    stderr.write 'Please provide an input file'
    1
  end

  def invalid_filename
    return if filename =~ suffix_regex
    stderr.write "#{filename.inspect} does not end in .testable_readme"
    1
  end

  def nonexistent_file
    return if file_class.exist? filename
    stderr.write "#{filename.inspect} does not exist"
    1
  end

  def execute!
    body = file_class.read filename
    file_class.write output_filename_for(filename), body
    0
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
