require 'spec_helper'

describe MountainBerryFields::Test::RubySyntaxChecker do
  it 'implements the SyntaxChecker interface' do
    Mock::SyntaxChecker.should substitute_for described_class
  end

  describe '#valid?' do
    it 'returns false for invalid syntax' do
      described_class.new("{").should_not be_valid
    end

    it 'returns true for valid syntax' do
      described_class.new("{}").should be_valid
    end
  end

  describe '#invalid_message' do
    it 'returns whatever Ruby gave it on the command line, followed by the original file' do
      described_class.new("{").invalid_message.should ==
        "-:1: syntax error, unexpected $end, expecting '}'\n"\
        "\n" \
        "original file:\n" \
        "{"
    end
  end
end
