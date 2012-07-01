require 'spec_helper'

describe MountainBerryFields::Commands::Test::RSpec do
  it 'is registered it the strategy list under :rspec' do
    MountainBerryFields::Commands::Test::Strategy.for(:rspec).should == described_class
  end

  let(:passing_spec) { <<-EOF.gsub /^ {4}/, '' }
    describe 'an example' do
      it('passes') { true.should be_true }
    end
  EOF

  let(:failing_spec) { <<-EOF.gsub /^ {4}/, '' }
    describe 'an example' do
      it('fails') { true.should be_false, 'the message' }
    end
  EOF

  let(:spec_with_two_failures) { <<-EOF.gsub /^ {4}/, '' }
    describe 'an example' do
      it('fails 1') { true.should be_false, 'failure message 1' }
      it('fails 2') { true.should be_false, 'failure message 2' }
    end
  EOF

  let(:file_class)  { Mock::File.clone }
  let(:dir_class)   { Mock::Dir.clone }
  let(:open3_class) { Mock::Open3.clone }
  let(:the_spec)    { passing_spec }

  it 'checks input syntax first' do
    rspec = described_class.new the_spec
    syntax_checker = rspec.syntax_checker
    syntax_checker.was initialized_with the_spec
    syntax_checker.will_have_valid? false  # rename to valid_syntax
    syntax_checker.will_have_invalid_message "you call that code?"
    rspec.pass?.should be_false
    rspec.failure_message.should == "you call that code?"
  end

  it 'writes the file to a temp dir' do
    rspec = described_class.new(the_spec).with_dependencies(dir_class: dir_class, file_class: file_class, open3_class: open3_class)
    dir_class.will_mktmpdir true
    rspec.pass?
    rspec.dir_class.was told_to(:mktmpdir).with('mountain_berry_fields_rspec') { |block|
      block.call_with '/temp_dir'
      block.before { file_class.was_not told_to :write }
      block.after  { file_class.was     told_to(:write).with("/temp_dir/spec.rb", the_spec) }
    }
  end

  it 'invokes rspec against the temp dir' do
    rspec = described_class.new(the_spec).with_dependencies(dir_class: dir_class, file_class: file_class, open3_class: open3_class)
    dir_class.will_mktmpdir true
    rspec.pass?
    rspec.dir_class.was told_to(:mktmpdir).with('mountain_berry_fields_rspec') { |block|
      block.call_with '/temp_dir'
      block.before { open3_class.was_not told_to :capture3 }
      block.after  { open3_class.was     told_to :capture3 } # not testing string directly, will let cukes verify it comes out right
    }
  end

  it 'passes when rspec executes successfully' do
    open3_class = Mock::Open3.clone.exit_with_success!
    rspec = described_class.new(the_spec).with_dependencies(dir_class: dir_class, file_class: file_class, open3_class: open3_class)
    rspec.pass?.should be_true

    open3_class = Mock::Open3.clone.exit_with_failure!
    rspec = described_class.new(the_spec).with_dependencies(dir_class: dir_class, file_class: file_class, open3_class: open3_class)
    rspec.pass?.should be_false
  end

  it 'pulls its failure message from the JSON output of the results, showing the description, message, and backtrace without the temp dir' do
    temp_dir = 'some_temp_dir'
    open3_class.will_capture3 [%'{"full_description":"THE DESCRIPTION","message":"THE MESSAGE","backtrace":["#{temp_dir}/THE BACKTRACE"]}', '', Mock::Process::ExitStatus.new]
    rspec = described_class.new(the_spec).with_dependencies(dir_class: dir_class, file_class: file_class, open3_class: open3_class)
    rspec.pass?
    dir_class.was told_to(:mktmpdir).with(anything) { |block| block.call_with temp_dir }
    rspec.failure_message.should include 'THE DESCRIPTION'
    rspec.failure_message.should include 'THE MESSAGE'
    rspec.failure_message.should include 'THE BACKTRACE'
  end
end

