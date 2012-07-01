require 'spec_helper'

describe Mock::File do
  it 'is substitutable for ::File' do
    Mock::File.should substitute_for ::File, subset: true
  end
end

describe Mock::Dir do
  it 'is substitutable for ::Dir' do
    Mock::Dir.should substitute_for Dir, subset: true
  end
end

describe Mock::Process::Status do
  it 'is substitutable for ::Process::Status' do
    Mock::Process::Status.should substitute_for ::Process::Status, subset: true
  end
end

describe Mock::Open3 do
  it 'is substitutable for ::Open3' do
    Mock::Open3.should substitute_for ::Open3, subset: true
  end
end
