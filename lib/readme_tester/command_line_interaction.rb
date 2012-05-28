class ReadmeTester
  class CommandLineInteraction
    Deject self
    dependency(:stderr) { $stderr }

    def declare_failure(failure_message)
      stderr.puts failure_message
    end
  end
end
