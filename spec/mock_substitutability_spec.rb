require 'spec_helper'

describe Mock::File do
  it 'is substitutable for ::File' do
    Mock::File.should substitute_for ::File, subset: true
  end
end
