SimpleCov.start do
  add_filter '/spec/'
  add_filter '/features/'

  # this gets acceptance tested, not unit tested
  add_filter 'formatter.rb'

  # don't look at coverage of plugins, let them test themselves
  add_filter do |source_file|
    !source_file.filename[File.dirname(__FILE__)+'/']
  end
end
