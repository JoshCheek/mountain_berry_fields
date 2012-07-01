require 'spec_helper'

test_class = MountainBerryFields::Commands::Test
describe test_class::AlwaysFail do
  it 'is registered it the strategy list under :always_pass' do
    test_class::Strategy.for(:always_fail).should == described_class
  end

  it 'evaluates the code' do
    $a = nil
    described_class.new('$a=1').pass?
    $a.should == 1
  end

  specify '#pass? evaluates the code and returns false even in the face of bullshit' do
    described_class.new("raise Exception, 'this will still pass'").should_not pass
    $abc = ''
    described_class.new("$abc=123").should_not pass
    $abc.should == 123
  end

  specify '#failure_message returns some bullshit about failing' do
    described_class.new('').failure_message.should be_a_kind_of String
  end
end
