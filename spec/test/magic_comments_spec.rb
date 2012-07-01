require 'spec_helper'

test_class = MountainBerryFields::Test

describe test_class::MagicComments do
  it 'is registered it the strategy list under :magic_comments' do
    test_class::Strategy.for(:magic_comments).should == described_class
  end

  specify '#pass? returns true if the output is the same as the input' do
    described_class.new('1 + 1 # => 2').should pass
    described_class.new('1 + 2 # => 2').should_not pass
    described_class.new("a=1\nb=2\na+b # => 3").should pass
  end

  it 'ignores warnings in the output' do
    described_class.new("1").should pass
  end

  it 'ignores differences that look like object inspections' do
    described_class.new("Object.new # => #<Object:0x007f9ef108b578>").should pass
    described_class.new("Object.new # => #<NotObject:0x007f9ef108b578>").should_not pass
    described_class.new("Class.new.new # => #<#<Class:0x007fc6d388b548>:0x007fc6d388b4f8>").should pass
  end

  describe '#failure_message' do
    it "provides Ruby's syntax message if the syntax is not valid" do
      magic_comments = described_class.new '}'
      syntax_checker = magic_comments.syntax_checker
      syntax_checker.was initialized_with '}'
      syntax_checker.will_have_valid? false  # should surrogate provide: will_be_valid? ?
      syntax_checker.will_have_invalid_message "} ain't no kinda valid"
      magic_comments.should_not pass
      magic_comments.failure_message.should == "} ain't no kinda valid"
    end

    it 'identifies the first output line that differs from the input' do
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
  end
end
