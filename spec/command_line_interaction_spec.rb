require 'spec_helper'

RSpec.describe MountainBerryFields::CommandLineInteraction do
  let(:interaction) { described_class.new }
  let(:stderr)      { interaction.stderr.string }

  it 'implements the interaction interface' do
    expect(MountainBerryFields::Interface::Interaction).to substitute_for MountainBerryFields::CommandLineInteraction, subset: true
  end

  specify '#declare_failure(message) writes messages to stderr, with newlines' do
    interaction.declare_failure "failure one"
    interaction.declare_failure "failure two"
    expect(stderr).to eq "failure one\nfailure two\n"
  end
end
