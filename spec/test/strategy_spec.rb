require 'spec_helper'

described_class = MountainBerryFields::Test::Strategy

RSpec.describe described_class do
  it 'is a module that you can mix into any class that wants to be a strategy' do
    expect(described_class).to be_a_kind_of Module
  end

  let(:strategy) { 'some strategy' }
  before { described_class.unregister :abc }

  describe 'registration' do
    specify 'a strategy can register itself with the .register method' do
      described_class.register :abc, strategy
      expect(described_class).to be_registered :abc
      expect(described_class).to be_registered 'abc'
    end

    specify 'a strategy can unregister itself with the .unregister method' do
      described_class.register :abc, strategy
      described_class.unregister 'abc'
      expect { described_class.for :abc }.to raise_error NameError, /abc/
    end

    specify 'a strategy can be retrieved with the .for method' do
      described_class.register 'abc', strategy
      expect(described_class.for :abc).to eq strategy
    end
  end


  context 'when mixing into a class' do
    let(:klass) { Class.new { include described_class } }

    it 'is initialized with the code to test, and stores it' do
      expect(klass.new("abc").code_to_test).to eq "abc"
    end

    it 'raises "unimplemented" when #pass? is invoked -- you should overwrite this method' do
      expect { klass.new('').pass? }.to raise_error "unimplemented"
    end

    it 'raises "unimplemented" when #failure_message is invoked -- you should overwrite this method' do
      expect { klass.new('').failure_message }.to raise_error "unimplemented"
    end
  end
end
