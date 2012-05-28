class ReadmeTester
  class Interpreter
    def initialize(to_interpret)
      @to_interpret = to_interpret
    end

    def tests_pass?
      true
    end

    def result
      @to_interpret
    end
  end
end
