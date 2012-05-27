class ReadmeTester
  class FileClass
    def self.exist?(filename)
      File.exist? filename
    end

    def self.write_file(filename, body)
      File.write filename, body
    end

    def self.read_file(filename)
      File.read filename
    end
  end
end
