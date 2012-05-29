require 'spec_helper'

test_class = ReadmeTester::Commands::Test
describe test_class::AlwaysFail do
  it 'is registered it the strategy list under :always_pass' do
    test_class::Strategy.for(:always_fail).should == described_class
  end

  specify '#pass? returns false' do
    described_class.new("# this test will still fail").pass?.should == false
  end

  specify '#failure_message returns some bullshit about failing' do
    described_class.new('').failure_message.should be_a_kind_of String
  end
end
