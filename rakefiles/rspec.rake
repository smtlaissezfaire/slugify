require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

desc 'Run the specs'
Spec::Rake::SpecTask.new do |t|
  t.warning = false
  t.spec_opts = ["--color"]
end

desc "Create the html specdoc"
Spec::Rake::SpecTask.new(:specdoc) do |t|
  t.spec_opts = ["--format", "html:doc/specdoc.html"]
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
  t.rcov_dir = "doc/rcov"
end

