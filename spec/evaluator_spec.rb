require 'spec_helper'

describe MountainBerryFields::Evaluator do
  it 'implements the evaluator interface' do
    Mock::Evaluator.should substitute_for described_class, subset: true
  end

  let(:to_evaluate) { '' }
  let(:evaluator)   { described_class.new to_evaluate }

  it 'has a document which is initialized to empty string and memoized' do
    evaluator = described_class.new ''
    evaluator.document.should == ''
    evaluator.document << 'abc'
    evaluator.document.should == 'abc'
  end

  def should_evaluate
    evaluator = described_class.new('def meth;end')
    evaluator.should_not respond_to :meth
    yield evaluator
    evaluator.should respond_to :meth
  end

  it 'ensures evaluation when asked for its document' do
    should_evaluate { |evaluator| evaluator.document }
  end

  it 'ensures evaluation when asked if tests pass' do
    should_evaluate { |evaluator| evaluator.tests_pass? }
  end

  describe 'evaluation' do
    it 'instance evals the string only once' do
      evaluator = described_class.new('def meth;end; document << "abc"')
      evaluator.evaluate
      evaluator.evaluate
      evaluator.document.should == 'abc'
    end
  end


  describe '#tests_pass?' do
    test_class = MountainBerryFields::Test

    it 'evaluates the text if not evaluated' do
      should_evaluate { |evaluator| evaluator.tests_pass? }
    end

    it 'returns true if all its tests pass' do
      evaluator = described_class.new ''
      evaluator.test('Passing test', with: :always_pass) {''}
      evaluator.tests_pass?.should == true
    end

    it 'tracks the failure name and message, if any of its tests fail' do
      evaluator = described_class.new ''
      evaluator.test('Failbert', with: :always_fail) {}
      evaluator.tests_pass?.should == false
      evaluator.failure_name.should == 'Failbert'
      evaluator.failure_message.should == MountainBerryFields::Test::Strategy.for(:always_fail).new('').failure_message
    end
  end

  describe 'visible and invisble commands' do
    specify '#visible_commands is an array of commands whose output should be displayed' do
      described_class.visible_commands.should be_a_kind_of Array
    end

    specify '#invisible_commands is an array of commands whose output should be omitted from the final document' do
      described_class.invisible_commands.should be_a_kind_of Array
    end
  end


  describe '#test' do
    it 'is visible' do
      described_class.visible_commands.should include :test
    end

    it 'adds a test with the given name, and options' do
      options   = { code: 'some code', with: :always_fail }
      evaluator = described_class.new ''
      evaluator.tests.size.should == 0
      evaluator.test('some name', options) { '' }
      evaluator.tests.size.should == 1
      evaluator.tests.first.name.should == 'some name'
      evaluator.tests.first.strategy.should == :always_fail
    end

    it 'immediately evaluates the test' do
      $abc = ''
      evaluator.test 'whatev', with: :always_pass do
        '$abc = "abc"'
      end
      $abc.should == 'abc'
    end
  end


  describe '#setup' do
    it 'is invisible' do
      described_class.invisible_commands.should include :setup
    end

    it 'is prepended before each test added after it' do
      evaluator.test('name', with: :always_pass) { "test1\n" }
      evaluator.setup { "setup\n" }
      evaluator.test('name', with: :always_pass) { "test2\n" }
      evaluator.test('name', with: :always_pass) { "test3\n" }
      evaluator.tests[0].code.should == "test1\n"
      evaluator.tests[1].code.should == "setup\ntest2\n"
      evaluator.tests[2].code.should == "setup\ntest3\n"
    end

    it 'appends to the setup code if invoked multiple times' do
      evaluator.setup { "setup1\n" }
      evaluator.setup { "setup2\n" }
      evaluator.test('name', with: :always_pass) { "test1\n" }
      evaluator.tests.first.code.should == "setup1\nsetup2\ntest1\n"
    end
  end


  describe '#context' do
    let(:context_name) { 'some context name' }
    let(:test_name)    { 'some test name' }

    it 'is invisible' do
      described_class.invisible_commands.should include :context
    end

    it 'must have at least one __CODE__ section in it' do
      expect {
        evaluator.context(context_name) { 'no code section' }
      }.to raise_error ArgumentError, /#{context_name}.*__CODE__/
    end

    it 'replaces all __CODE__ section with the test using it' do
      evaluator.context(context_name) { 'a __CODE__ c __CODE__' }
      evaluator.test(test_name, with: :always_pass, context: context_name) { 'b' }
      evaluator.tests.first.code.should == 'a b c b'
    end

    it 'raises an error when a test references a nonexistent context' do
      evaluator.context(context_name) { '__CODE__' }
      expect {
        evaluator.test(test_name, with: :always_pass, context: context_name.reverse) {''}
      }.to raise_error NameError, /#{context_name.reverse}.*#{context_name}/
    end

    it 'is applied after setup' do
      evaluator.setup { 'a' }
      evaluator.context(context_name) { ' b __CODE__' }
      evaluator.test(test_name, context: context_name, with: :always_pass) { 'c' }
      evaluator.tests.first.code.should == 'a b c'
    end

    let(:context_name1) { 'context name 1' }
    let(:context_name2) { 'context name 2' }
    specify 'contexts can have contexts of their own' do
      evaluator.context(context_name1) { 'a __CODE__ b' }
      evaluator.context(context_name2, context: context_name1) { 'c __CODE__ d' }
      evaluator.test(test_name, context: context_name1, with: :always_pass) { 'e' }
      evaluator.test(test_name, context: context_name2, with: :always_pass) { 'f' }
      evaluator.tests[0].code.should == 'a e b'
      evaluator.tests[1].code.should == 'a c f d b'
    end
  end
end
