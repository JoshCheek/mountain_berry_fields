require 'spec_helper'

test_class = MountainBerryFields::Test
RSpec.describe test_class::AlwaysFail do
  it 'is registered it the strategy list under :always_pass' do
    expect(test_class::Strategy.for :always_fail).to eq described_class
  end

  it 'evaluates the code' do
    $a = nil
    described_class.new('$a=1').pass?
    expect($a).to eq 1
  end

  specify '#pass? evaluates the code and returns false even in the face of bullshit' do
    expect(described_class.new "raise Exception, 'this will still pass'").to_not pass
    $abc = ''
    expect(described_class.new "$abc=123").to_not pass
    expect($abc).to eq 123
  end

  specify '#failure_message returns some bullshit about failing' do
    expect(described_class.new('').failure_message).to be_a_kind_of String
  end
end
