require 'erubis'

class ReadmeTester

  # This class takes a document with erb in it
  # It parses the erb and gives you back a file of source code
  # When that source code is evaluated, you get the file out.
  # The evaluation environment is expected to provide a `document` method or local variable,
  # which is a string that the template will be appended to.
  #
  # It differs from normal ERB in that you can pass it :visible and :invisible commands lists.
  # Code inside of a block around an invisible command (method name) will not be added to the document.
  # Any command invoked at the start of an erb block (<% and <%=) will be checked against the
  # visible and invisible lists, if they are on either list, their block will return the
  # text in the template that was written in the block.
  class Parser < Erubis::Eruby
    class Recording
      def initialize(is_command, is_visible=true)
        @is_command = is_command
        @is_visible = is_visible
      end

      def command?
        @is_command
      end

      def visible?
        @is_visible
      end

      def recorded
        @recorded ||= ''
      end

      def record(text)
        recorded << text if command?
      end
    end

    attr_accessor :visible_commands, :invisible_commands, :known_commands, :recordings

    def init_generator(properties={})
      self.recordings         = [Recording.new(false)]
      self.visible_commands   = (properties.delete(:visible)   || []).map &:to_s
      self.invisible_commands = (properties.delete(:invisible) || []).map &:to_s
      self.known_commands     = visible_commands + invisible_commands
      super
    end

    def add_preamble(src)
      super
    end

    def add_postamble(src)
      src << "#{@bufvar} << %(\\n) unless #{@bufvar}.end_with? %(\\n);"
      src << "document << #{@bufvar};"
    end

    def parse
      src
    end

    def add_text(src, text)
      recordings.last.record text
      super if recordings.last.visible?
    end

    def known_command?(code_with_command)
      known_commands.include? code_with_command[/\w+/]
    end

    def visible_command?(code_with_command)
      visible_commands.include? code_with_command[/\w+/]
    end

    def end_command?(code_with_command)
      code_with_command =~ /\A\s*(end|})/
    end

    def add_stmt(src, code)
      manage_recording src, code
      super
    end

    def add_expr_literal(src, code)
      manage_recording src, code
      super
    end

    def manage_recording(src, code)
      if known_command? code
        recordings << Recording.new(true, visible_command?(code))
      elsif end_command? code
        recording = recordings.pop
        src << recording.recorded.inspect << ";" if recording.command?
      else
        recordings << Recording.new(false)
      end
    end
  end
end
