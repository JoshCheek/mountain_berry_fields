# Not all implementations implement File.write (e.g. rubinius and Jruby < 1.7)
# This just presents a common interface

class MountainBerryFields
  class File < ::File
    def self.write(filename, body)
      open filename, 'w' do |file|
        file.write body
      end
    end
  end
end
