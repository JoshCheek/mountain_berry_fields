SimpleCov.merge_timeout 3600

SimpleCov.add_filter '/spec/'
SimpleCov.add_filter '/features/'

# don't look at coverage of plugins, let them test themselves
SimpleCov.add_filter do |source_file|
  !source_file.filename[File.dirname(__FILE__)+'/']
end
