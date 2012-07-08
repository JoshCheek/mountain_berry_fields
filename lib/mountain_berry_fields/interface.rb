# like Rake, I'm not making this a hard dependency of the lib
# but if you want to test against it, or substitute your own class
# in place of any of these, it makes sense to depend on Surrogate at least in your test env,
# in order to assert substitutability
require 'surrogate'

class MountainBerryFields
  module Interface
    class Evaluator
      Surrogate.endow self do
        define(:visible_commands)   { [:visible] }
        define(:invisible_commands) { [:invisible] }
      end

      define(:initialize)      { @document = '' }
      define(:tests_pass?)     { true }
      define(:test)            { |test, &block| block.call }
      define(:failure_message) { 'some failure message' }
      define(:failure_name)    { 'failing test name' }
      define(:document)
    end

    class Parser
      Surrogate.endow self
      define(:initialize) {}
      define(:parse) { 'some body' }
      define(:parsed) { parse }
    end

    class File
      Surrogate.endow self do
        define(:exist?) { true }
        define(:write)  { true }
        define(:read)   { "file contents" }
      end
    end

    class Dir
      Surrogate.endow self do
        define(:chdir)    { |dir,    &block| block.call }
        define(:mktmpdir) { |prefix, &block| block.call }
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
      define(:declare_failure) { }
    end
  end
end

