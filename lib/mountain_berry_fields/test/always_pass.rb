class MountainBerryFields
  class Test

    # Ask it if it passes
    #
    # (it does)
    class AlwaysPass
      Strategy.register :always_pass, self

      include Strategy

      def pass?
        eval code_to_test
      ensure
        return true
      end
    end
  end
end
