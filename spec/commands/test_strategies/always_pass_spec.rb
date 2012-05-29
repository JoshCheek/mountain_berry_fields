require 'spec_helper'

test_class = ReadmeTester::Commands::Test
describe test_class::AlwaysPass do
  it 'is registered it the strategy list under :always_pass' do
    test_class::Strategy.for(:always_pass).should == described_class
  end

  specify '#pass? returns true' do
    described_class.new("raise 'this will still pass'").pass?.should == true
  end
end
