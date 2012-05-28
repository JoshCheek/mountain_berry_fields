Given 'the file "$filename"' do |filename, body|
  in_proving_grounds { File.write filename, body }
end

When 'I run "$command"' do |command|
  in_proving_grounds { cmdline command }
end

Then /^it exits with a status of (\d+)$/ do |status|
  last_cmdline.exitstatus.should == status.to_i
end

Then /^it exits with a status of (\d+), and a stderr of$/ do |status, stderr|
  last_cmdline.exitstatus.should == status.to_i
  last_cmdline.stderr.chomp.should == interpret_curlies(stderr).chomp
end

Then 'I see the file "$filename"' do |filename, body|
  in_proving_grounds { File.read(filename).should == body }
end
