require 'spec_helper'

RSpec.describe MountainBerryFields::Evaluator do
  it 'implements the evaluator interface' do
    expect(MountainBerryFields::Interface::Evaluator).to substitute_for described_class, subset: true
  end

  let(:to_evaluate) { '' }
  let(:evaluator)   { described_class.new to_evaluate }

  it 'has a document which is initialized to empty string and memoized' do
    evaluator = described_class.new ''
    expect(evaluator.document).to eq ''
    evaluator.document << 'abc'
    expect(evaluator.document).to eq 'abc'
  end

  def should_evaluate
    evaluator = described_class.new('def meth;end')
    expect(evaluator).to_not respond_to :meth
    yield evaluator
    expect(evaluator).to respond_to :meth
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
      expect(evaluator.document).to eq 'abc'
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
      expect(evaluator.tests_pass?).to eq true
    end

    it 'tracks the failure name and message, if any of its tests fail' do
      evaluator = described_class.new ''
      evaluator.test('Failbert', with: :always_fail) {}
      expect(evaluator.tests_pass?).to eq false
      expect(evaluator.failure_name).to eq 'Failbert'
      expect(evaluator.failure_message).to eq MountainBerryFields::Test::Strategy.for(:always_fail).new('').failure_message
    end
  end

  describe 'visible and invisble commands' do
    specify '#visible_commands is an array of commands whose output should be displayed' do
      expect(described_class.visible_commands).to be_a_kind_of Array
    end

    specify '#invisible_commands is an array of commands whose output should be omitted from the final document' do
      expect(described_class.invisible_commands).to be_a_kind_of Array
    end
  end


  describe '#test' do
    it 'is visible' do
      expect(described_class.visible_commands).to include :test
    end

    it 'adds a test with the given name, and options' do
      options   = { code: 'some code', with: :always_fail }
      evaluator = described_class.new ''
      expect(evaluator.tests.size).to eq 0
      evaluator.test('some name', options) { '' }
      expect(evaluator.tests.size).to eq 1
      expect(evaluator.tests.first.name).to eq 'some name'
      expect(evaluator.tests.first.strategy).to eq :always_fail
    end

    it 'immediately evaluates the test' do
      $abc = ''
      evaluator.test 'whatev', with: :always_pass do
        '$abc = "abc"'
      end
      expect($abc).to eq 'abc'
    end
  end


  describe '#setup' do
    it 'is invisible' do
      expect(described_class.invisible_commands).to include :setup
    end

    it 'is prepended before each test added after it' do
      evaluator.test('name', with: :always_pass) { "test1\n" }
      evaluator.setup { "setup\n" }
      evaluator.test('name', with: :always_pass) { "test2\n" }
      evaluator.test('name', with: :always_pass) { "test3\n" }
      expect(evaluator.tests[0].code).to eq "test1\n"
      expect(evaluator.tests[1].code).to eq "setup\ntest2\n"
      expect(evaluator.tests[2].code).to eq "setup\ntest3\n"
    end

    it 'appends to the setup code if invoked multiple times' do
      evaluator.setup { "setup1\n" }
      evaluator.setup { "setup2\n" }
      evaluator.test('name', with: :always_pass) { "test1\n" }
      expect(evaluator.tests.first.code).to eq "setup1\nsetup2\ntest1\n"
    end
  end


  describe '#context' do
    let(:context_name) { 'some context name' }
    let(:test_name)    { 'some test name' }

    it 'is invisible' do
      expect(described_class.invisible_commands).to include :context
    end

    it 'must have at least one __CODE__ section in it' do
      expect {
        evaluator.context(context_name) { 'no code section' }
      }.to raise_error ArgumentError, /#{context_name}.*__CODE__/
    end

    it 'replaces all __CODE__ section with the test using it' do
      evaluator.context(context_name) { 'a __CODE__ c __CODE__' }
      evaluator.test(test_name, with: :always_pass, context: context_name) { 'b' }
      expect(evaluator.tests.first.code).to eq 'a b c b'
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
      expect(evaluator.tests.first.code).to eq 'a b c'
    end

    let(:context_name1) { 'context name 1' }
    let(:context_name2) { 'context name 2' }
    specify 'contexts can have contexts of their own' do
      evaluator.context(context_name1) { 'a __CODE__ b' }
      evaluator.context(context_name2, context: context_name1) { 'c __CODE__ d' }
      evaluator.test(test_name, context: context_name1, with: :always_pass) { 'e' }
      evaluator.test(test_name, context: context_name2, with: :always_pass) { 'f' }
      expect(evaluator.tests[0].code).to eq 'a e b'
      expect(evaluator.tests[1].code).to eq 'a c f d b'
    end
  end
end
