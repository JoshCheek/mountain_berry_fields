require 'spec_helper'

describe ReadmeTester do
  let(:file_class)  { readme_tester.file_class }
  let(:stderr)      { readme_tester.stderr.string }
  let(:interaction) { readme_tester.interaction }
  let(:evaluator)   { readme_tester.evaluator }
  let(:parser)      { readme_tester.parser }

  shared_examples 'a failure' do
    it 'returns exit status 1' do
      readme_tester.execute.should == 1
    end

    it 'does not write any files' do
      file_class.should_not have_been_told_to :write
    end
  end


  context 'when no input file is provided' do
    nonexistence_message = 'Please provide an input file'
    let(:readme_tester) { described_class.new [] }

    it_behaves_like 'a failure'

    it "declares the error '#{nonexistence_message}'" do
      readme_tester.execute
      interaction.should have_been_told_to(:declare_failure).with(nonexistence_message)
    end
  end


  context 'when the input file does not exist' do
    nonexistent_filename = '/some/bullshit/file.md.testable_readme'.freeze
    nonexistence_message = "#{nonexistent_filename.inspect} does not exist.".freeze

    let(:readme_tester) { described_class.new [nonexistent_filename] }
    before { file_class.will_exist? false }

    it_behaves_like 'a failure'

    it "declares the error '#{nonexistent_filename}'" do
      readme_tester.execute
      file_class.should have_been_asked_for_its(:exist?).with(nonexistent_filename)
      interaction.should have_been_told_to(:declare_failure).with(nonexistence_message)
    end
  end


  context 'when the input file does not have a suffix of .testable_readme' do
    invalid_filename         = "invalid_filename.md"
    invalid_filename_message = "#{invalid_filename.inspect} does not end in .testable_readme"
    let(:readme_tester) { described_class.new [invalid_filename] }

    it "declares the error '#{invalid_filename_message}'" do
      readme_tester.execute
      interaction.should have_been_told_to(:declare_failure).with(invalid_filename_message)
    end
  end

  context 'when unsuccessfully parsing a file' do
    let(:input_filename)   { 'some_invalid_file.md.testable_readme' }
    let(:readme_tester)    { described_class.new [input_filename] }
    before { parser.will_parse StandardError.new "some error message" }

    it_behaves_like 'a failure'

    it 'writes the exception class and message as the error' do
      readme_tester.execute
      interaction.should have_been_told_to(:declare_failure).with("StandardError some error message")
    end
  end

  context 'when successfully parsing a file' do
    let(:input_filename)     { 'some_valid_file.md.testable_readme' }
    let(:output_filename)    { 'some_valid_file.md' }
    let(:readme_tester)      { described_class.new [input_filename] }
    let(:file_body)          { 'SOME FILE BODY' }
    let(:parsed_body)        { 'PARSED BODY' }
    let(:document)           { 'EVALUATED DOCUMENT' }

    before { file_class.will_read file_body }
    before { parser.will_parse parsed_body }

    it 'declares no errors' do
      readme_tester.execute
      interaction.should_not have_been_told_to :declare_failure
    end

    it 'passes the file contents to the parser' do
      visible_commands = readme_tester.evaluator_class.visible_commands
      invisible_commands = readme_tester.evaluator_class.invisible_commands
      readme_tester.execute
      file_class.should have_been_told_to(:read).with(input_filename)
      parser.should have_been_initialized_with file_body, visible: visible_commands, invisible: invisible_commands
    end

    it 'evaluates the results of the parsing' do
      readme_tester.execute
      evaluator.should have_been_initialized_with parsed_body
    end


    context 'when the tests pass' do
      before { evaluator.will_tests_pass? true }
      before { evaluator.will_have_document document }

      it 'returns exit status 0' do
        readme_tester.execute.should == 0
      end

      it 'writes the interpreted file to the new filename (the same name, but with .testable_readme removed)' do
        readme_tester.execute
        file_class.should have_been_told_to(:write).with(output_filename, document)
      end
    end

    context 'when the tests fail' do
      before { evaluator.will_tests_pass? false }
      it_behaves_like 'a failure'
      it "declares the failure with the evaluator's failure message" do
        evaluator.will_have_failure_message "faiiil"
        readme_tester.execute
        interaction.should have_been_told_to(:declare_failure).with("faiiil")
      end
    end

    context 'when evaluation raises an exception' do
      before { evaluator.will_tests_pass? StandardError.new('blah') }
      it_behaves_like 'a failure'
      it 'writes the exception class and message as the error' do
        readme_tester.execute
        interaction.should have_been_told_to(:declare_failure).with("StandardError blah")
      end
    end
  end
end
