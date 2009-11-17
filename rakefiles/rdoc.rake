require 'rake'
require 'hanna/rdoctask'

DOC_DIRECTORY = File.dirname(__FILE__) + "/../doc"

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = DOC_DIRECTORY
  rdoc.title    = 'slugify'
  rdoc.options << '--line-numbers' << '--inline-source'

  rdoc.options << '--webcvs=http://github.com/smtlaissezfaire/slugify'

  ["README.rdoc", "GPL_LICENSE", "MIT_LICENSE", "lib/**/*.rb"].each do |file|
    rdoc.rdoc_files.include(file)
  end
end
