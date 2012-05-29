require 'spec_helper'

describe ReadmeTester::Evaluator do
  it 'implements the evaluator interface' do
    Mock::Evaluator.should substitute_for described_class, subset: true
  end

  describe '#tests_pass?' do
    test_class = ReadmeTester::Commands::Test

    it 'returns true if all its tests pass' do
      evaluator = described_class.new
      evaluator.add_test 'Passing test', strategy: :always_pass
      evaluator.tests_pass?.should == true
    end

    it 'returns the failure message, if any of its tests fail' do
      evaluator = described_class.new
      evaluator.add_test 'Failing Test', strategy: :always_fail
      evaluator.tests_pass?.should == false
      evaluator.failure_message.should == ReadmeTester::Commands::Test::Strategy.for(:always_fail).new('').failure_message
    end
  end

  describe '#add_test' do
    it 'adds a test with the given name, and options' do
      options   = { code: 'some code', strategy: :some_strategy }
      evaluator = described_class.new
      evaluator.tests.size.should == 0
      evaluator.add_test 'some name', options
      evaluator.tests.size.should == 1
      evaluator.tests.first.name.should == 'some name'
      evaluator.tests.first.strategy.should == :some_strategy
    end
  end
end
