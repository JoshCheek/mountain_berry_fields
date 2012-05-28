require 'spec_helper'

describe ReadmeTester::Interpreter do
  it 'implements the interpreter interface' do
    Mock::Interpreter.should substitute_for described_class, subset: true
  end

  specify 'for now, tests always pass and result is same as init' do
    tester = described_class.new("blah")
    tester.tests_pass?.should == true
    tester.result.should == "blah"
  end
end
