require 'spec_helper'

module ReadmeTester::Commands
  describe Test do
    let(:name)          { 'Some name' }
    let(:code)          { 'Some code' }
    let(:strategy_name) { :always_pass }
    let(:test)          { described_class.new name, code: code, strategy: strategy_name }

    context 'the :strategy option' do
      it 'tells it the name of its strategy' do
        test.strategy.should == strategy_name
      end
    end

    context 'the :code option' do
      it 'provides the code that it is testing' do
        test.code.should == code
      end
    end
  end
end
