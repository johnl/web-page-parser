Gem::Specification.new do |s|
  s.name    = 'web-page-parser'
  s.version = '1.0.0'
  s.date    = '2014-10-25'
  s.licenses = ['MIT']
  
  s.summary = "A parser for various news organisation's web pages"
  s.description = "A Ruby library to parse the content out of web pages. Currently supports BBC News pages, The Guardian, Independent and New York Times articles. Used by the News Sniffer project. http://www.newssniffer.co.uk"
  
  s.authors  = ['John Leach']
  s.email    = 'john@johnleach.co.uk'
  s.homepage = 'http://github.com/johnl/web-page-parser'

  s.cert_chain  = ['certs/johnleach.pem']
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/
  
  s.has_rdoc = true

  s.files = Dir.glob("lib/**/*")
  s.test_files = Dir.glob("spec/**/*")

  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]

  s.add_dependency("htmlentities", "~> 4.3")
  s.add_dependency("curb", "~> 0.8")
  s.add_dependency("nokogiri", "~> 1.6")
  s.add_development_dependency("rspec", "~> 2.11")
  s.add_development_dependency("rake")
end
