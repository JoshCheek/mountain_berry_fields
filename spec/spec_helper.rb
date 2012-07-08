require 'simplecov'

require 'mountain_berry_fields'
require 'mountain_berry_fields/command_line_interaction'

require 'stringio'
require 'surrogate/rspec'
require 'mountain_berry_fields/interface'


RSpec::Matchers.define :pass do
  match { |matcher| matcher.pass? }
end

MountainBerryFields.override(:file_class)      { MountainBerryFields::Interface::File.clone }
MountainBerryFields.override(:dir_class)       { MountainBerryFields::Interface::Dir.clone }
MountainBerryFields.override(:interaction)     { MountainBerryFields::Interface::Interaction.new }
MountainBerryFields.override(:evaluator_class) { MountainBerryFields::Interface::Evaluator.clone }
MountainBerryFields.override(:parser_class)    { MountainBerryFields::Interface::Parser.clone }

MountainBerryFields::CommandLineInteraction.override(:stderr) { StringIO.new }
MountainBerryFields::Test::RSpec.override(:syntax_checker_class) { MountainBerryFields::Interface::SyntaxChecker }
MountainBerryFields::Test::MagicComments.override(:syntax_checker_class) { MountainBerryFields::Interface::SyntaxChecker }
