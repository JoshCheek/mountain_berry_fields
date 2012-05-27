Given 'the file "$filename"' do |filename, body|
  in_proving_grounds { File.write filename, body }
end

When 'I run "$command"' do |command|
  in_proving_grounds { system command }
end

Then 'I see "$filename"' do |filename, body|
  in_proving_grounds { File.read(filename).should == body }
end
