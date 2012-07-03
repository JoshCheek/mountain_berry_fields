<%
# STRATEGIES (maybe some of these should be pulled into their own gems? they seem generally useful)
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

# MountainBerryFields::Test::Strategy.register
%>

# ReadmeTester

Tests code in readme files, generates the readme if they are successful.

## Usage

When you have a file with embedded code samples, rename it to include a .mountain_berry_fields suffix.
Then wrap test statements around the code samples. I've written two testing strategies: rspec and magic_comments.
You can create your own without much effort.


### Code samples with magic comments

You will need to
`<% test('dep magic_comments', with: :install_dep) { %>$ gem install mountain_berry_fields-magic_comments<% } %>`
for this to work.

