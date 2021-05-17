Gem::Specification.new do |s|
  s.name    = 'web-page-parser'
  s.version = '1.3.0'
  s.date    = '2019-11-03'
  s.licenses = ['MIT']

  s.summary = "A parser for various news organisation's web pages"
  s.description = "A Ruby library to parse the content out of web pages. Currently supports BBC News pages, The Guardian, Independent, New York Times, RT, Washington Post and The Intercept articles. Used by the News Sniffer project. https://www.newssniffer.co.uk"

  s.authors  = ['John Leach']
  s.email    = 'john@johnleach.co.uk'
  s.homepage = 'https://github.com/johnl/web-page-parser'

  s.cert_chain  = ['certs/johnleach.pem']
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  s.files = Dir.glob("lib/**/*")
  s.test_files = Dir.glob("spec/**/*")

  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]

  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency("htmlentities", "~> 4.3")
  s.add_dependency("curb", "~> 0.9.10")
  s.add_dependency("nokogiri", ">= 1.9.1", "< 1.12.0")
  s.add_development_dependency("rspec", "~> 2.11")
  s.add_development_dependency("rake")
end
