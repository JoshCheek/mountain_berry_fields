require 'spec_helper'

test_class = MountainBerryFields::Test
RSpec.describe test_class::AlwaysPass do
  it 'is registered it the strategy list under :always_pass' do
    expect(test_class::Strategy.for :always_pass).to eq described_class
  end

  specify '#pass? evaluates the code and returns true even in the face of bullshit' do
    expect(described_class.new "raise Exception, 'this will still pass'").to pass
    $abc = ''
    expect(described_class.new "$abc=123").to pass
    expect($abc).to eq 123
  end
end
