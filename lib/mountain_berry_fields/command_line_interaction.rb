class MountainBerryFields

  # Iinteractions are used by the MountainBerryFields to let the users know what's going on.
  # This one interacts with the command line.
  class CommandLineInteraction
    Deject self
    dependency(:stderr) { $stderr }

    def declare_failure(failure_message)
      stderr.puts failure_message
    end
  end
end
