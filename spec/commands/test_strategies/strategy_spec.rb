require 'spec_helper'

described_class = MountainBerryFields::Commands::Test::Strategy

describe described_class do
  it 'is a module that you can mix into any class that wants to be a strategy' do
    described_class.should be_a_kind_of Module
  end

  let(:strategy) { 'some strategy' }
  before { described_class.unregister :abc }

  describe 'registration' do
    specify 'a strategy can register itself with the .register method' do
      described_class.register :abc, strategy
      described_class.should be_registered :abc
      described_class.should be_registered 'abc'
    end

    specify 'a strategy can unregister itself with the .unregister method' do
      described_class.register :abc, strategy
      described_class.unregister 'abc'
      expect { described_class.for :abc }.to raise_error NameError, /abc/
    end

    specify 'a strategy can be retrieved with the .for method' do
      described_class.register 'abc', strategy
      described_class.for(:abc).should == strategy
    end
  end


  context 'when mixing into a class' do
    let(:klass) { Class.new { include described_class } }

    it 'is initialized with the code to test, and stores it' do
      klass.new("abc").code_to_test.should == "abc"
    end

    it 'raises "unimplemented" when #pass? is invoked -- you should overwrite this method' do
      expect { klass.new('').pass? }.to raise_error "unimplemented"
    end

    it 'raises "unimplemented" when #failure_message is invoked -- you should overwrite this method' do
      expect { klass.new('').failure_message }.to raise_error "unimplemented"
    end
  end
end
