require 'spec_helper'

describe ReadmeTester::Parser do
  let(:evaluator) { Mock::Evaluator.new }

  def parsed(text)
    described_class.new(text, evaluator).parse
  end

  it 'interprets text as text' do
    parsed("abc\n").should == "abc\n"
  end

  it 'results always end with a newline' do
    parsed("abc").should == "abc\n"
  end

  it 'removes <% valid_comand %> lines' do
    parsed("a\n<% test 'name', strategy: :always_pass %>\n b\n c\n<% end %>").should == "a\n b\n c\n"      # shit in the middle
    parsed("a\n \t<% test 'name', strategy: :always_pass %>\n  b\n \t<% end %>").should == "a\n  b\n"      # leading whitespace
    parsed("a\n\n<% test 'name', strategy: :always_pass %>\n<% end %>\n\nb").should == "a\n\n\nb\n"        # multiple newlines
  end

  it 'raises a YoDawgThisIsntReallyERB error on <% not_valid_command %> lines' do
    expect { parsed "a\n<% if true %>do shit<% end %>" }.to raise_error ReadmeTester::YoDawgThisIsntReallyERB, /" if true "/
  end

  # what should it do for inline?

  it 'raises a YoDawgThisIsntReallyERB error for <%= ... %> lines' do
    expect { parsed "a\n<%= b %>\n<% end %>\n" }.to raise_error ReadmeTester::YoDawgThisIsntReallyERB, /<%= b %>/
  end

  specify 'unbalanced code (commands within commands, ends without commands) raises an error' do
    expect_error = lambda do |regex, code|
      expect { parsed code }.to raise_error ReadmeTester::UnbalancedCommands, regex
    end
    expect_error[/nested commands/i, "<% test 'name', strategy: :always_pass %><% test 'name2', strategy: :always_pass %><% end %><% end %>"]
    expect_error[/end without an open command/i, "<% end %>"]
  end
end
