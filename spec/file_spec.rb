require 'spec_helper'

describe MountainBerryFields::File do
  it 'implements the File interface' do
    Mock::File.should substitute_for described_class, subset: true
  end

  describe '.write' do
    it 'writes the body to the filename' do
      Dir.mktmpdir do |dir|
        Dir.chdir dir do
          described_class.write("a", "b")
          ::File.read("a").should == "b"
        end
      end
    end
  end
end
