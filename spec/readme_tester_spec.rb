require 'spec_helper'

describe ReadmeTester::FileClass do
  it 'is substitutable for the mock file class' do
    Mock::FileClass.should substitute_for described_class
  end
end

describe ReadmeTester do
  let(:file_class) { readme_tester.file_class }
  let(:stderr)     { readme_tester.stderr.string }

  shared_examples 'a failure' do
    it 'returns exit status 1' do
      readme_tester.execute.should == 1
    end

    it 'does not write any files' do
      file_class.should_not have_been_told_to :write_file
    end
  end


  context 'when no input file is provided' do
    nonexistence_message = 'Please provide an input file'
    let(:readme_tester) { described_class.new [] }

    it_behaves_like 'a failure'

    it "writes '#{nonexistence_message}' to stderr" do
      readme_tester.execute
      stderr.should include nonexistence_message
    end
  end


  context 'when the input file does not exist' do
    nonexistent_filename = '/some/bullshit/file.md.testable_readme'.freeze
    nonexistence_message = "#{nonexistent_filename.inspect} does not exist".freeze

    let(:readme_tester) { described_class.new [nonexistent_filename] }
    before { file_class.will_exist? false }

    it_behaves_like 'a failure'

    it "writes '#{nonexistent_filename}' to stderr" do
      readme_tester.execute
      file_class.should have_been_asked_for_its(:exist?).with(nonexistent_filename)
      stderr.should include nonexistence_message
    end
  end


  context 'when the input file does not have a suffix of .testable_readme' do
    invalid_filename         = "invalid_filename.md"
    invalid_filename_message = "#{invalid_filename.inspect} does not end in .testable_readme"
    let(:readme_tester) { described_class.new [invalid_filename] }

    it "writes '#{invalid_filename_message}' to stderr" do
      readme_tester.execute
      stderr.should include invalid_filename_message
    end
  end


  context 'when given the name of a file that exists' do
    let(:input_filename)  { 'some_valid_file.md.testable_readme' }
    let(:output_filename) { 'some_valid_file.md' }
    let(:readme_tester)   { described_class.new [input_filename] }
    let(:file_body)       { "SOME FILE BODY" }

    before { file_class.will_read_file file_body }

    it 'writes nothing to stderr' do
      readme_tester.execute
      stderr.should be_empty
    end

    it 'reads the input file' do
      readme_tester.execute
      file_class.should have_been_told_to(:read_file).with(input_filename)
    end

    # it 'passes the file contents to the interpreter'

    # it 'tests the interpretation'

    # context 'when the tests pass' do
      it 'returns exit status 0' do
        readme_tester.execute.should == 0
      end

      # eventually it will write the extracted file to the new filename
      it 'writes the same file to the new filename (the same name, but with .testable_readme removed)' do
        readme_tester.execute
        file_class.should have_been_told_to(:write_file).with(output_filename, file_body)
      end
    # end

    # context 'when the tests fail' do
    #   it_behaves_like 'a failure'
    #   it 'writes "tests do not pass" to stderr'
    # end
  end
end
