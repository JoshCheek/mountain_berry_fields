require 'spec_helper'

describe MountainBerryFields::Parser do
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

  it 'parses normal erb code' do
    parsed("a\n<% if true %>\ndo shit\n<% end %>b").should == "a\ndo shit\nb\n"
    parsed("a\n<% if false %>do shit<% end %>b").should == "a\nb\n"
    parsed("a<% if true %>b<% end %>c").should == "abc\n"
    parsed("a<%= 1 + 2 %>b").should == "a3b\n"
    parsed("a<%# comment %>b").should == "ab\n"
    parsed("a<%% whatev %>b").should == "a<% whatev %>b\n"
    parsed("a<%%= whatev %>b").should == "a<%= whatev %>b\n"
    parsed("a<% if 'I' %>b<% end %>c").should == "abc\n"
    recorded_args("a<% record_args 'I' %>").should == ['I']
    recorded_args("a<%= record_args 'I' %>").should == ['I']
  end

  specify 'results always end with a newline' do
    parsed("abc").should == "abc\n"
  end

  describe 'visible methods' do
    specify 'are provided in a list to the constructor and converted to strings' do
      described_class.new('', visible: [:a]).visible_commands.should == ['a']
    end

    specify 'default to an empty array' do
      described_class.new('').visible_commands.should == []
    end

    specify 'show up in the document when evaluated' do
      parsed("a<% visible do %>b<% end %>c").should == "abc\n"
    end

    specify 'are returned when the block is invoked' do
      visible_in("a<% visible do %>b<% end %>c").should == ['b']
    end

    specify "support basic nesting (can't do complex nesting without editing parse trees -- not a big deal, these are things that even erubis can't do)" do
      visible_in("a<%visible {%>b<%visible {%>c<% } %>d<% } %>e").should == ['c', 'bd']
      visible_in("a<%visible {%>b<%if false %>c<% end %>d<% } %>e").should == ['bd']
      visible_in("<%# visible %>").should == []
      visible_in('<% visible do %>\'a\'\\<% end %>').should == ['\'a\'\\']
    end
  end

  describe 'invisible methods' do
    specify 'are provided in a list to the constructor and converted to strings' do
      described_class.new('', invisible: [:a]).invisible_commands.should == ['a']
    end

    specify 'default to an empty array' do
      described_class.new('').invisible_commands.should == []
    end

    specify 'do not show up in the document when evaluated' do
      parsed("a<% invisible do %>b<% end %>c").should == "ac\n"
    end

    specify 'are returned when the block is invoked' do
      invisible_in("a<% invisible do %>b<% end %>c").should == ['b']
    end

    specify "support basic nesting (can't do complex nesting without editing parse trees -- not a big deal, these are things that even erubis can't do)" do
      invisible_in("a<%invisible {%>b<%invisible {%>c<% } %>d<% } %>e").should == ['c', 'bd']
      invisible_in("a<%invisible {%>b<%if false %>c<% end %>d<% } %>e").should == ['bd']
      invisible_in("<%# invisible %>").should == []
      invisible_in('<% invisible do %>\'a\'\\<% end %>').should == ['\'a\'\\']
    end
  end

  # Unfortunately, this problem is in Erubis.
  # It might be possible to fix it in the subclass,
  # but that seems like a lot of work for an incredibly rare use case
  # so just going to leave this pending for now.
  #
  # Erubis::Eruby.new('<% a = "<% b %>"; a * 2 %>').src # => "_buf = ''; a = \"<% b ; _buf << '\"; a * 2 %>';\n_buf.to_s\n"
  xit 'ignores erb tags inside erb blocks' do
    parse("a<% s='<% visible { %>b<% } %>' %>c").should == "ac\n"
    parsed("a<% s='<% invisible { %>b<% } %>' %>c").should == "ac\n"
  end
end
