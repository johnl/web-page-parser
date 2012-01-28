module WebPageParser
  class GuardianPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new("(www\.)?guardian\.co\.uk/[a-z-]+(/[a-z-]+)?/[0-9]{4}/[a-z]{3}/[0-9]{1,2}/[a-z-]{5,200}$")

    def self.can_parse?(options)
      URL_RE.match(options[:url])
    end
    
    def self.create(options = {})
      GuardianPageParserV4.new(options)
    end
  end

  # BbcNewsPageParserV1 parses BBC News web pages exactly like the
  # old News Sniffer BbcNewsPage class did.  This should only ever
  # be used for backwards compatability with News Sniffer and is
  # never supplied for use by a factory.
  class GuardianPageParserV1 < WebPageParser::BaseParser
    ICONV = nil
    TITLE_RE = ORegexp.new('<meta property="og:title" content="(.*)"', 'i')
    DATE_RE = ORegexp.new('<meta property="article:published_time" content="(.*)"', 'i')
    CONTENT_RE = ORegexp.new('article-body-blocks">(.*?)<div id="related"', 'm')
    STRIP_TAGS_RE = ORegexp.new('</?(a|span|div|img|tr|td|!--|table)[^>]*>','i')
    PARA_RE = Regexp.new(/<(p|h2)[^>]*>(.*?)<\/\1>/i)

    private
    
    def date_processor
      begin
        # OPD is in GMT/UTC, which DateTime seems to use by default
        @date = DateTime.parse(@date)
      rescue ArgumentError
        @date = Time.now.utc
      end
    end

    def content_processor
      @content = STRIP_TAGS_RE.gsub(@content, '')
      @content = @content.scan(PARA_RE).collect { |a| a[1] }
    end
    
  end
end
