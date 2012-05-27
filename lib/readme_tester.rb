require 'deject'
require 'readme_tester/version'
require 'readme_tester/file_class'

def ReadmeTester(argv)
  ReadmeTester.new(argv).execute
end

class ReadmeTester
  Deject self, :stdin, :stdout, :stderr, :file_class

  def initialize(argv)
    self.argv = argv
  end

  def execute
    filename = argv.first
    if !filename
      stderr.write 'Please provide an input file'
      1
    elsif filename !~ /\.testable_readme$/
      stderr.write "#{filename.inspect} does not end in .testable_readme"
      1
    elsif !file_class.exist?(filename)
      stderr.write "#{filename.inspect} does not exist"
      1
    else
      body = file_class.read_file filename
      file_class.write_file output_filename_for(filename), body
      0
    end
  end

private

  def output_filename_for(filename)
    filename.sub /\.testable_readme/, ''
  end

  attr_accessor :argv
end
