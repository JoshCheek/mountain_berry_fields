require 'spec_helper'

describe ReadmeTester::Evaluator do
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

  specify 'evaluation consists of instance evaling the string only once' do
    evaluator = described_class.new('def meth;end; document << "abc"')
    evaluator.document.should == 'abc'
    evaluator.tests_pass?
    evaluator.document.should == 'abc'
  end

  describe '#tests_pass?' do
    test_class = ReadmeTester::Commands::Test

    it 'evaluates the text if not evaluated' do
    end

    it 'returns true if all its tests pass' do
      evaluator = described_class.new ''
      evaluator.add_test 'Passing test', strategy: :always_pass
      evaluator.tests_pass?.should == true
    end

    it 'returns the failure message, if any of its tests fail' do
      evaluator = described_class.new ''
      evaluator.add_test 'Failing Test', strategy: :always_fail
      evaluator.tests_pass?.should == false
      evaluator.failure_message.should == ReadmeTester::Commands::Test::Strategy.for(:always_fail).new('').failure_message
    end
  end

  describe '#add_test' do
    it 'adds a test with the given name, and options' do
      options   = { code: 'some code', strategy: :some_strategy }
      evaluator = described_class.new ''
      evaluator.tests.size.should == 0
      evaluator.add_test 'some name', options
      evaluator.tests.size.should == 1
      evaluator.tests.first.name.should == 'some name'
      evaluator.tests.first.strategy.should == :some_strategy
    end
  end
end
