require 'spec_helper'

RSpec.describe MountainBerryFields::Interface::File do
  it 'is substitutable for ::File' do
    expect(MountainBerryFields::Interface::File).to substitute_for ::File, subset: true
  end
end

RSpec.describe MountainBerryFields::Interface::Dir do
  it 'is substitutable for ::Dir' do
    expect(MountainBerryFields::Interface::Dir).to substitute_for Dir, subset: true
  end
end
