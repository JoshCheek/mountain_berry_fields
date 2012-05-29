require 'spec_helper'

describe ReadmeTester::Evaluator do
  it 'implements the evaluator interface' do
    Mock::Evaluator.should substitute_for described_class, subset: true
  end

  it 'interprets text as text'
  it 'removes <% ... %> lines'
  it 'ignores <%= ... %> lines'

  context '<% test "name", strategy: :strategy_name %> code <% end %>' do
    it "records the test's name"
    it "records the test's strategy name"
    it "records the test's code"
  end

  # # Whatever
  #
  #     <% test 'I will pass', strategy: :always_pass %>
  #     some code
  #     <% end %>

  # # Whatever
  #
  # Some text
  #     some code
  specify 'for now, tests always pass and result is same as init' do
    tester = described_class.new("blah")
    tester.tests_pass?.should == true
    tester.result.should == "blah"
  end
end
