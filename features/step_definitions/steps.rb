Given 'the file "$filename":' do |filename, body|
  in_proving_grounds do
    ensure_dir File.dirname filename
    File.write filename, interpret_curlies(body)
  end
end

When 'I run "$command"' do |command|
  in_proving_grounds { cmdline command }
end

Then /^it exits with a status of (\d+)$/ do |status|
  last_cmdline.exitstatus.should eq(status.to_i), "Expected #{status}, got #{last_cmdline.exitstatus}. STDERR: #{last_cmdline.stderr}"
end

Then /^it exits with a status of (\d+), and a stderr of:$/ do |status, stderr|
  last_cmdline.exitstatus.should == status.to_i
  last_cmdline.stderr.chomp.should == interpret_curlies(stderr).chomp
end

Then /^it prints nothing to (stdout|stderr)$/ do |descriptor|
  last_cmdline.send(descriptor).should == ''
end

Then 'I see the file "$filename"' do |filename|
  in_proving_grounds { File.exist?(filename).should be_true }
end

Then 'I see the file "$filename":' do |filename, body|
  in_proving_grounds do
    File.exist?(filename).should be_true, "#{filename} doesn't exist"

    body && strip_trailing_whitespace(File.read(filename)).should ==
            strip_trailing_whitespace(body)
  end
end

Then 'I do not see the file "$filename"' do |filename|
  in_proving_grounds { File.exist?(filename).should be_false }
end

And 'I pry' do
  require 'pry'
  binding.pry
end

