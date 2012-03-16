$spec = Gem::Specification.new do |s|
  s.name        = "slugify"
  s.description = "Generate slugs for your ActiveRecord models"
  s.version     = Slugify::Version
  s.summary     = "Generate slugs for your models"

  s.authors   = ['Scott Taylor', 'Stephen Schor']
  s.email     = ['scott@railsnewbie.com', 'beholdthepanda@gmail.com']
  s.homepage  = 'https://github.com/smtlaissezfaire/slugify'

  s.files         = Dir['lib/*','lib/slugify/*']
  
  s.rubyforge_project = 'nowarning'
  
  s.add_dependency              'iconv', '>= 0.1'
end