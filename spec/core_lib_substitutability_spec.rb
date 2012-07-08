require 'spec_helper'

describe MountainBerryFields::Interface::File do
  it 'is substitutable for ::File' do
    MountainBerryFields::Interface::File.should substitute_for ::File, subset: true
  end
end

describe MountainBerryFields::Interface::Dir do
  it 'is substitutable for ::Dir' do
    MountainBerryFields::Interface::Dir.should substitute_for Dir, subset: true
  end
end
