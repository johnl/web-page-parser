class TestPageParserFactory < WebPageParser::ParserFactory
  @url_regexp = Regexp.new("www.example.com")

  def self.can_parse?(url, page = nil)
    @url_regexp.match(url)
  end

  def self.create(url, page = nil)
    TestPageParser.new(:url => url, :page => page)
  end
end

class TestPageParser < WebPageParser::BaseParser

end
