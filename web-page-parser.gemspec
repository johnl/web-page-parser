Gem::Specification.new do |s|
  s.name    = 'web-page-parser'
  s.version = '0.26'
  s.date    = '2012-08-25'
  s.rubyforge_project = "web-page-parser"
  
  s.summary = "A parser for web pages"
  s.description = "A Ruby library to parse the content out of web pages. Currently sypports BBC News pages, Guardian and New York Times articles. Used by the News Sniffer project."
  
  s.authors  = ['John Leach']
  s.email    = 'john@johnleach.co.uk'
  s.homepage = 'http://github.com/johnl/web-page-parser/tree/master'
  
  s.has_rdoc = true

	s.files = Dir.glob("lib/**/*")
	s.test_files = Dir.glob("spec/**/*")

	s.extra_rdoc_files = ["README.rdoc", "LICENSE"]

  s.add_dependency("htmlentities", ">=4.0.0")
  s.add_dependency("curb", ">=0.8")
end
