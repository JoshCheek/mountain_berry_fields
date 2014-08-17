require 'spec_helper'

RSpec.describe MountainBerryFields::Test::RubySyntaxChecker do
  it 'implements the SyntaxChecker interface' do
    expect(MountainBerryFields::Interface::SyntaxChecker).to substitute_for described_class
  end

  describe '#valid?' do
    it 'returns false for invalid syntax' do
      expect(described_class.new "{").to_not be_valid
    end

    it 'returns true for valid syntax' do
      expect(described_class.new "{}").to be_valid
    end
  end

  describe '#invalid_message' do
    it 'returns whatever Ruby gave it on the command line, followed by the original file' do
      expect(described_class.new("{").invalid_message).to include 'syntax error'
    end
  end
end
