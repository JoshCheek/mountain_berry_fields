SimpleCov.start do
  add_filter '/spec/'
  add_filter '/features/'
  add_filter 'formatter.rb' # this gets acceptance tested, not unit tested
end
