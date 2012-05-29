class ReadmeTester
  module Commands
    Test = Struct.new :name, :options do
      def strategy
        options[:strategy]
      end

      def code
        options[:code]
      end
    end
  end
end
