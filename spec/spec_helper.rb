require 'simplecov'

require 'mountain_berry_fields'
require 'mountain_berry_fields/command_line_interaction'

require 'stringio'
require 'surrogate/rspec'
require 'mountain_berry_fields/interface'


RSpec::Matchers.define :pass do
  match { |matcher| matcher.pass? }
end

# dependency injection
class MountainBerryFields
  override(:file_class)      { Interface::File.clone }
  override(:dir_class)       { Interface::Dir.clone }
  override(:interaction)     { Interface::Interaction.new }
  override(:evaluator_class) { Interface::Evaluator.clone }
  override(:parser_class)    { Interface::Parser.clone }

  CommandLineInteraction.override(:stderr) { StringIO.new }
  Test::RSpec.override(:syntax_checker_class) { Interface::SyntaxChecker }
  Test::MagicComments.override(:syntax_checker_class) { Interface::SyntaxChecker }
end
