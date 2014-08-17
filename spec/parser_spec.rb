require 'spec_helper'

RSpec.describe MountainBerryFields::Parser do
  let :evaluator_class do
    Class.new do
      attr_reader :document, :visible_saw, :invisible_saw

      def initialize
        @document = ''
        @visible_saw = []
        @invisible_saw = []
      end

      def visible
        @visible_saw << yield
        'visible'
      end

      def invisible
        @invisible_saw << yield
        'invisible'
      end

      def record_args(*args)
        @recorded_args = args
      end

      def recorded_args
        @recorded_args
      end

      def inspect
        "#<evaluator_class>"
      end
    end
  end

  attr_reader :evaluator

  def visible_in(code)
    parsed code
    evaluator.visible_saw
  end

  def invisible_in(code)
    parsed code
    evaluator.invisible_saw
  end

  def recorded_args(code)
    parsed code
    evaluator.recorded_args
  end

  def parsed(text)
    program = described_class.new(text, visible: [:visible], invisible: [:invisible]).parse
    @evaluator = evaluator_class.new
    @evaluator.instance_eval program
    @evaluator.document
  end

  def assert_parsed(pre, post)
    expect(parsed pre).to eq post
  end

  it 'parses normal erb code' do
    assert_parsed "a\n<% if true %>\ndo shit\n<% end %>b", "a\ndo shit\nb\n"
    assert_parsed "a\n<% if false %>do shit<% end %>b",    "a\nb\n"
    assert_parsed "a<% if true %>b<% end %>c",             "abc\n"
    assert_parsed "a<%= 1 + 2 %>b",                        "a3b\n"
    assert_parsed "a<%# comment %>b",                      "ab\n"
    assert_parsed "a<%% whatev %>b",                       "a<% whatev %>b\n"
    assert_parsed "a<%%= whatev %>b",                      "a<%= whatev %>b\n"
    assert_parsed "a<% if 'I' %>b<% end %>c",              "abc\n"
    expect(recorded_args "a<% record_args 'I' %>").to eq ['I']
    expect(recorded_args "a<%= record_args 'I' %>").to eq ['I']
  end

  specify 'results always end with a newline' do
    assert_parsed "abc", "abc\n"
  end

  describe 'visible methods' do
    specify 'are provided in a list to the constructor and converted to strings' do
      expect(described_class.new('', visible: [:a]).visible_commands).to eq ['a']
    end

    specify 'default to an empty array' do
      expect(described_class.new('').visible_commands).to eq []
    end

    specify 'show up in the document when evaluated' do
      assert_parsed "a<% visible do %>b<% end %>c", "abc\n"
    end

    def assert_visible(pre, post)
      expect(visible_in pre).to eq post
    end
    specify 'are returned when the block is invoked' do
      assert_visible "a<% visible do %>b<% end %>c", ['b']
    end

    specify "support basic nesting (can't do complex nesting without editing parse trees -- not a big deal, these are things that even erubis can't do)" do
      assert_visible "a<%visible {%>b<%visible {%>c<% } %>d<% } %>e",    ['c', 'bd']
      assert_visible "a<%visible {%>b<%if false %>c<% end %>d<% } %>e",  ['bd']
      assert_visible "<%# visible %>",                                   []
      assert_visible '<% visible do %>\'a\'\\<% end %>',                 ['\'a\'\\']
    end
  end

  describe 'invisible methods' do
    specify 'are provided in a list to the constructor and converted to strings' do
      expect(described_class.new('', invisible: [:a]).invisible_commands).to eq ['a']
    end

    specify 'default to an empty array' do
      expect(described_class.new('').invisible_commands).to eq []
    end

    specify 'do not show up in the document when evaluated' do
      assert_parsed "a<% invisible do %>b<% end %>c", "ac\n"
    end

    def assert_invisible(pre, post)
      expect(invisible_in pre).to eq post
    end

    specify 'are returned when the block is invoked' do
      assert_invisible "a<% invisible do %>b<% end %>c", ['b']
    end

    specify "support basic nesting (can't do complex nesting without editing parse trees -- not a big deal, these are things that even erubis can't do)" do
      assert_invisible "a<%invisible {%>b<%invisible {%>c<% } %>d<% } %>e", ['c', 'bd']
      assert_invisible "a<%invisible {%>b<%if false %>c<% end %>d<% } %>e", ['bd']
      assert_invisible "<%# invisible %>",                                  []
      assert_invisible '<% invisible do %>\'a\'\\<% end %>',                ['\'a\'\\']
    end
  end

  # Unfortunately, this problem is in Erubis.
  # It might be possible to fix it in the subclass,
  # but that seems like a lot of work for an incredibly rare use case
  # so just going to leave this pending for now.
  #
  # Erubis::Eruby.new('<% a = "<% b %>"; a * 2 %>').src # => "_buf = ''; a = \"<% b ; _buf << '\"; a * 2 %>';\n_buf.to_s\n"
  xit 'ignores erb tags inside erb blocks' do
    parsed("a<% s='<% visible { %>b<% } %>' %>c").should == "ac\n"
    parsed("a<% s='<% invisible { %>b<% } %>' %>c").should == "ac\n"
  end
end
