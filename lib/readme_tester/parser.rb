class ReadmeTester
  YoDawgThisIsntReallyERB = Class.new StandardError
  UnbalancedCommands      = Class.new StandardError

  class Parser
    attr_accessor :original_source, :evaluator

    include Erubis::Evaluator
    include Erubis::Basic::Converter
    include Erubis::Generator

    def initialize(source, evaluator)
      init_generator Hash.new
      init_converter trim: true
      init_evaluator Hash.new

      self.original_source = source
      self.evaluator = evaluator
    end

    def parse
      @parsed ||= convert original_source
    end

    def parsed
      @parsed
    end

    # temp method I'm using to track how Erubis hands me things
    def record(name, *args)
      puts "RECORDED: #{name}(#{args.map(&:inspect).join ', '})"
    end

    def add_text(src, text)
      current_command_code << text if in_command?
      src << text
    end

    def add_stmt(src, code)
      remove_last_line src if last_line_empty?(src)
      if known_command? code
        start_command code
      elsif end_command? code
        end_current_command
      else
        raise YoDawgThisIsntReallyERB, "It doesn't support #{code.inspect}, it only supports #{evaluator.known_commands}"
      end
    end

    def add_expr_literal(src, code)
      raise YoDawgThisIsntReallyERB, "It doesn't support <%=#{code}%>"
    end

    def add_expr_escaped(src, code)
      record :add_expr_escaped, src, code
    end

    def add_expr_debug(src, code)
      # do nothing
    end

    def add_preamble(src)
      # do nothing
    end

    def add_postamble(src)
      src << "\n" unless src.end_with? "\n"
    end

    def remove_last_line(src)
      src.sub! /^.*?\z/, ''
    end

    def last_line_empty?(src)
      src =~ /^\s+\z/
    end

    def start_command(code)
      raise UnbalancedCommands, "Document has nested commands, can't do #{code.inspect}" if in_command?
      self.current_command = code
      self.current_command_code = ''
    end

    def end_current_command
      raise UnbalancedCommands, "You have an end without an open command" unless in_command?
      add_command current_command, current_command_code
      self.current_command = self.current_command_code = nil
    end

    def add_command(code_containing_command, body)
      eval "evaluator.add_#{code_containing_command.sub(/^\s*/, '').chomp}, code: body"
    end

    def end_command?(code_containing_command)
      code_containing_command[/\w+/] == 'end'
    end

    def known_command?(code_containing_command)
      evaluator.known_commands.include? code_containing_command[/\w+/]
    end

    def in_command?
      !!current_command
    end

    attr_accessor :current_command_code, :current_command
  end
end
