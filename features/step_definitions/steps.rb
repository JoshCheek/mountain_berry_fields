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
  expect(last_cmdline.exitstatus).to eq(status.to_i), "Expected #{status}, got #{last_cmdline.exitstatus}. STDERR: #{last_cmdline.stderr}"
end

Then /^it exits with a status of (\d+), and a stderr of:$/ do |status, stderr|
  expect(last_cmdline.exitstatus).to eq status.to_i
  expect(last_cmdline.stderr.chomp).to eq interpret_curlies(stderr).chomp
end

Then /^it prints nothing to (stdout|stderr)$/ do |descriptor|
  expect(last_cmdline.send descriptor).to eq ''
end

Then 'I see the file "$filename"' do |filename|
  in_proving_grounds { expect(File.exist? filename).to be_truthy }
end

Then 'I see the file "$filename":' do |filename, body|
  in_proving_grounds do
    expect(File.exist? filename).to be_truthy, "#{filename} doesn't exist"

    body and expect(strip_trailing_whitespace File.read filename).to eq \
            strip_trailing_whitespace(body)
  end
end

Then 'I do not see the file "$filename"' do |filename|
  in_proving_grounds { expect(File.exist? filename).to be_falsy }
end

And 'I pry' do
  require 'pry'
  binding.pry
end

