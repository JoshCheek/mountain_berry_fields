# like Rake, I'm not making this a hard dependency of the lib
# but if you want to test against it, or substitute your own class
# in place of any of these, it makes sense to depend on Surrogate at least in your test env,
# in order to assert substitutability
require 'surrogate'
require 'tmpdir'

class MountainBerryFields
  module Interface
    class Evaluator
      Surrogate.endow self do
        define(:visible_commands)   { [:visible] }
        define(:invisible_commands) { [:invisible] }
      end

      define(:initialize)      { |to_evaluate| @document = '' }
      define(:tests_pass?)     { true }
      define(:test)            { |test, options={}, &block| block.call }
      define(:failure_message) { 'some failure message' }
      define(:failure_name)    { 'failing test name' }
      define(:document)
    end

    class Parser
      Surrogate.endow self
      define(:initialize) { |is_command, is_visible=true| }
      define(:parse)      { 'some body' }
      define(:parsed)     { parse }
    end

    class File
      Surrogate.endow self do
        define(:exist?) { |filename|       true }
        define(:write)  { |filename, body| true }
        define(:read)   { |filename|       "file contents" }
      end
    end

    class Dir
      Surrogate.endow self do
        define(:chdir)    { |dir, &block| block.call }
        define(:mktmpdir) { |prefix=nil, *, &block| block.call }
      end
    end

    class SyntaxChecker
      Surrogate.endow self
      define(:initialize) { |syntax| }
      define(:valid?) { true }
      define(:invalid_message) { "shit ain't valid" }
    end

    class Interaction
      Surrogate.endow self
      define(:declare_failure) { |message| }
    end
  end
end

