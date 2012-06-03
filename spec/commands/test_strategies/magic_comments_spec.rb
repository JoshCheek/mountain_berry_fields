require 'spec_helper'

test_class = MountainBerryFields::Commands::Test

describe test_class::MagicComments do
  it 'is registered it the strategy list under :magic_comments' do
    test_class::Strategy.for(:magic_comments).should == described_class
  end

  specify '#pass? returns true if the output is the same as the input' do
    described_class.new('1 + 1 # => 2').pass?.should == true
    described_class.new('1 + 2 # => 2').pass?.should == false
    described_class.new("a=1\nb=2\na+b # => 3").pass?.should == true
  end

  it 'ignores warnings in the output' do
    described_class.new("1").pass?.should == true
  end

  describe '#failure_message' do
    it 'identifies the first different line' do
      magic_comments = described_class.new <<-CODE.gsub(/^\s*/, '')
        1 + 2     # => 3
        "a" + "b" # => "ba"
        5 + 6     # => 345678
      CODE
      magic_comments.pass?
      magic_comments.failure_message.should == %Q(Expected: "a" + "b" # => "ba"\n) +
                                               %Q(Actual:   "a" + "b" # => "ab"\n)
    end

    it 'strips leading white spaces off of failures' do
      magic_comments = described_class.new("    \t\t   1 + 1 # => 4")
      magic_comments.pass?
      magic_comments.failure_message.should == %Q(Expected: 1 + 1 # => 4\n) +
                                               %Q(Actual:   1 + 1 # => 2\n)
    end

    it 'identifies missing output' do
      magic_comments = described_class.new("puts 1\nputs 2\n")
      magic_comments.pass?
      magic_comments.failure_message.should == "Output had extra line: # >> 1\n"
    end

    it 'identifies missing input' do
      magic_comments = described_class.new("puts 1\n# >> 1\n# >> 2\n")
      magic_comments.pass?
      magic_comments.failure_message.should == "Input had extra line: # >> 2\n"
    end

    it 'ignores differences that look like object inspections' do
      described_class.new("Object.new # => #<Object:0x007f9ef108b578>").pass?.should == true
      described_class.new("Object.new # => #<NotObject:0x007f9ef108b578>").pass?.should == false
      described_class.new("Class.new.new # => #<#<Class:0x007fc6d388b548>:0x007fc6d388b4f8>").pass?.should == true
    end
  end
end
