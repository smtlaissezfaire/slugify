def sloc
  `sloccount #{File.dirname(__FILE__)}/../lib #{File.dirname(__FILE__)}/../ext`
end

desc "Output sloccount report.  You'll need sloccount installed."
task :sloc do
  puts "Counting lines of code"
  puts sloc
end

desc "Write sloccount report"
task :output_sloc => :create_doc_directory do
  File.open(File.dirname(__FILE__) + "/doc/lines_of_code.txt", "w") do |f|
    f << sloc
  end
end