class TestPageParserFactory < WebPageParser::ParserFactory
  @url_regexp = Regexp.new("www.example.com")

  def self.can_parse?(options = {})
    @url_regexp.match(options[:url])
  end

  def self.create(options = {})
    TestPageParser.new(options)
  end
end

class TestPageParser < WebPageParser::BaseParser

end
