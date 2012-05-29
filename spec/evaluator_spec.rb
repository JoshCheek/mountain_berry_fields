require 'spec_helper'

describe ReadmeTester::Evaluator do
  it 'implements the evaluator interface' do
    Mock::Evaluator.should substitute_for described_class, subset: true
  end

  def result_for(text)
    described_class.new(text).result
  end

  it 'interprets text as text' do
    result_for("abc\n").should == "abc\n"
  end

  it 'results always end with a newline' do
    result_for("abc").should == "abc\n"
  end

  it 'removes <% valid_comand %> lines' do
    result_for("a\n<% test 'name', strategy: :always_pass %>\n b\n c\n<% end %>").should == "a\n b\n c\n"
    result_for("a\n <% test 'name', strategy: :always_pass %>\n <% end %>").should == "a\n"
  end

  it 'raises a YoDawgThisIsntReallyERB error on <% not_valid_command %> lines' do
    expect { result_for "a\n<% if true %>do shit<% end %>" }.to raise_error ReadmeTester::YoDawgThisIsntReallyERB, /" if true "/
  end

  # what should it do for inline?

  it 'raises a YoDawgThisIsntReallyERB error for <%= ... %> lines' do
    expect { result_for "a\n<%= b %>\n<% end %>\n" }.to raise_error ReadmeTester::YoDawgThisIsntReallyERB, /<%= b %>/
  end

  specify 'unbalanced code (commands within commands, ends without commands) raises an error' do
    expect_error = lambda do |regex, code|
      expect { result_for code }.to raise_error ReadmeTester::UnbalancedCommands, regex
    end
    expect_error[/nested commands/i, "<% test 'name', strategy: :always_pass %><% test 'name2', strategy: :always_pass %><% end %><% end %>"]
    expect_error[/end without an open command/i, "<% end %>"]
  end

  context 'the test command' do
    let(:test)          { described_class.new(text).tests.first }
    let(:test_name)     { 'some test name' }
    let(:strategy_name) { :always_pass }
    let(:test_code)     { 'some test code' }
    let(:text)          { "some bullshit\n<% test #{test_name.inspect}, strategy: #{strategy_name.inspect} %>\n#{test_code}\n<% end %>\nmore bullshit" }

    it "records the test's name" do
      test.name.should == test_name
    end

    # eventually it will be able to specify a strategy or a context
    it "records the test's strategy name" do
      test.strategy.should == strategy_name
    end

    it "records the test's code" do
      test.code.chomp.should == test_code
    end
  end
end
