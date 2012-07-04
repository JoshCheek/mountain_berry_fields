# Okay look, I know this code is scary, and you're like "I don't want to
# have to do that shit for my project". But it's not likely that you will,
# I didn't have to when I did Deject or Surrogate, it's just that this
# code is embedding readmes in readmes, so they're not really code samples.


# maybe this should be pulled into its own gem? it seems generally useful
MountainBerryFields::Test::Strategy.register :install_dep, Class.new {
  include MountainBerryFields::Test::Strategy

  def initialize(install_string)
    @prompt, @gem_command, @install_command, @dependency_name = install_string.split
    @gemspec = Gem::Specification.load 'mountain_berry_fields.gemspec'
  end

  def pass?
    !failure_message
  end

  def failure_message
    return %'prompt marker is "$", not #{@prompt.inspect}' unless @prompt == '$'
    return %'gem command is "gem", not #{@gem_command.inspect}' unless @gem_command == 'gem'
    return %'install command is "install", not #{@install_command.inspect}' unless @install_command == 'install'
    return %'development dependencies are #{development_dependencies.inspect} WTF is #{@dependency_name.inspect}?' unless is_dependency?
  end

  def development_dependencies
    @gemspec.development_dependencies.map &:name
  end

  def is_dependency?
    development_dependencies.include? @dependency_name
  end
}


require 'tmpdir'
require 'open3'
MountainBerryFields::Test::Strategy.register :mbf_example, Class.new {
  include MountainBerryFields::Test::Strategy

  attr_accessor :input_filename, :input_code, :command_line_invocation, :output_filename, :output_code, :expected_failure, :failure_message

  def pass?
    parse
    happy_path && sad_path
  end

  def failure_message
    @failure_message
  end

  def happy_path
    happy_lib_code = '
    <% setup do %>
      MyLibName = Struct.new :data do
        def result
          "some cool result"
        end
      end
    <% end %>
    '
    Dir.mktmpdir 'happy_path' do |dir|
      Dir.chdir dir do
        File.write input_filename, happy_lib_code + input_code
        out, err, status = Open3.capture3 command_line_invocation
        @failure_message = err
        status.success? && File.exist?(dir + "/" + output_filename)
      end
    end
  end

  def sad_path
    sad_lib_code = '
    <% setup do %>
      MyLibName = Struct.new :data do
        def result
          "some unexpected result"
        end
      end
    <% end %>
    '
    Dir.mktmpdir 'happy_path' do |dir|
      Dir.chdir dir do
        File.write input_filename, sad_lib_code + input_code
        oout, err, status = Open3.capture3 command_line_invocation
        self.failure_message = "Error should have been #{expected_failure.inspect}, but was #{err.inspect}"
        result =( expected_failure == err)
        result
      end
    end
  end

  # all this parsing is overly simple and a bit fragile, but good enough
  # revisit it after v2, should have something in place so we don't have to parse
  # the text, but can instead talk directly to the test or something
  def parse
    results = code_to_test.split(/^(?=\S)/)
    parse_setup      results.shift
    parse_happy_path results.shift
    parse_sad_path   results.shift
  end

  def parse_setup(raw_setup)
    lines = raw_setup.lines.to_a
    self.input_filename = lines.shift[/`(.*?)`/, 1]
    lines.shift
    lines.pop
    self.input_code = lines.join.gsub(/^ {4}/, '')
  end

  def parse_happy_path(raw_happy_path)
    lines = raw_happy_path.lines.to_a
    first_line = lines.shift
    self.command_line_invocation, self.output_filename = first_line.scan(/`[^`]*`/).map { |text| text[1...-1] }
    command_line_invocation.sub! /^\$\s+/, ''
    lines.shift
    lines.pop
    self.output_code = lines.join.gsub(/^ {4}/, '')
  end

  def parse_sad_path(raw_sad_path)
    self.expected_failure = raw_sad_path.lines.drop(2).join.gsub(/^ {4}/, '')
  end
}


MountainBerryFields::Test::Strategy.register :requires_lib, Class.new {
  include MountainBerryFields::Test::Strategy

  attr_accessor :setup_block, :failure_message

  def initialize(setup_block)
    self.setup_block = setup_block
  end

  def pass?
    test_block = '
      <% test "loaded", with: :magic_comments do %>
      MyLibName # => 12
      <% end %>
    '
    Dir.mktmpdir 'setup_block' do |dir|
      Dir.chdir dir do
        Dir.mkdir 'lib'
        File.write 'lib/my_lib_name.rb', 'MyLibName = 12'
        File.write 'f.mountain_berry_fields', setup_block + test_block
        out, err, status = Open3.capture3 "mountain_berry_fields f.mountain_berry_fields"
        self.failure_message = err
        status.success?
      end
    end
  end
}
