$spec = Gem::Specification.new do |s|
  s.name        = "slugify"
  s.description = "Generate slugs for your ActicveRecord models"
  s.version     = '0.1.4'
  s.summary     = "A Command-Line tool for exploring your flickr account"

  s.authors   = ['Scott Taylor', 'Stephen Schor']
  s.email     = ['scott@railsnewbie.com', 'beholdthepanda@gmail.com']
  s.homepage  = 'https://github.com/nodanaonlyzuul/flickr_cli'

  s.files         = Dir['lib/*','lib/slugify/*']

  s.rubyforge_project = 'nowarning'
end