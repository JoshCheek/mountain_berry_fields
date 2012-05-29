require 'spec_helper'

describe ReadmeTester::Evaluator do
  it 'implements the evaluator interface' do
    Mock::Evaluator.should substitute_for described_class, subset: true
  end

  # describe '#tests_pass?'

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
