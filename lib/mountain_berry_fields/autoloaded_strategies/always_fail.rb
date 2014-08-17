class MountainBerryFields
  class Test

    # Red. Red. Refactor anyway, cuz fuck it.
    class AlwaysFail
      Strategy.register :always_fail, self

      include Strategy

      def pass?
        eval code_to_test
      ensure
        return false
      end

      def failure_message
        "THIS STRATEGY ALWAYS FAILS"
      end
    end
  end
end
