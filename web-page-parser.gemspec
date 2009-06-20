Gem::Specification.new do |s|
  s.name    = 'web-page-parser'
  s.version = '0.10'
  s.date    = '2009-06-20'
  s.rubyforge_project = "web-page-parser"
  
  s.summary = "A parser for web pages"
  s.description = "A Ruby library to parse the content out of web pages, such as BBC News pages.  Used by the News Sniffer project."
  
  s.authors  = ['John Leach']
  s.email    = 'john@johnleach.co.uk'
  s.homepage = 'http://github.com/johnl/web-page-parser/tree/master'
  
  s.has_rdoc = true

	s.files = Dir.glob("lib/**/*")
	s.test_files = Dir.glob("spec/**/*")

	s.extra_rdoc_files = ["README.rdoc", "LICENSE"]

	s.add_dependency("oniguruma", ">=1.1.0")
	s.add_dependency("htmlentities", ">=4.0.0")
end
