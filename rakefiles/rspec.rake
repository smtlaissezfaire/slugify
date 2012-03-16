require 'rspec/core/rake_task'

desc 'Run the specs'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--backtrace --color']
  t.pattern = 'spec/slugify/*_spec.rb'
end

desc "Generate code coverage"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

