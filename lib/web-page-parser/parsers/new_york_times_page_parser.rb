module WebPageParser
  class NewYorkTimesPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new("www\.nytimes\.com/[0-9]{4}/[0-9]{2}/[0-9]{2}/.+\.html$")
    INVALID_URL_RE = ORegexp.new("/cartoon/")
    def self.can_parse?(options)
      return nil if INVALID_URL_RE.match(options[:url])
      URL_RE.match(options[:url])
    end
    
    def self.create(options = {})
      NewYorkTimesPageParserV1.new(options)
    end
  end

  # BbcNewsPageParserV1 parses BBC News web pages exactly like the
  # old News Sniffer BbcNewsPage class did.  This should only ever
  # be used for backwards compatability with News Sniffer and is
  # never supplied for use by a factory.
  class NewYorkTimesPageParserV1 < WebPageParser::BaseParser
    ICONV = nil
    TITLE_RE = ORegexp.new('<nyt_headline [^>]*>(.*)</nyt_headline>', 'i')
    DATE_RE = ORegexp.new('<meta name="dat" content="(.*)"', 'i')
    CONTENT_RE = ORegexp.new('<nyt_text[^>]*>(.*)</nyt_text', 'mi')
    STRIP_TAGS_RE = ORegexp.new('</?(a|strong|span|div|img|tr|td|!--|table|ul|li)[^>]*>','i')
    PARA_RE = Regexp.new('<(p)[^>]*>(.*?)<\/\1>', 'i')
    STRIP_INLINE_BLOCK = ORegexp.new('<div class="articleInline.*<div class="articleBody[^>]*>', 'm')

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
      @content = STRIP_INLINE_BLOCK.gsub(@content, '')
      @content = STRIP_TAGS_RE.gsub(@content, '')
      @content = @content.scan(PARA_RE).collect { |a| a[1] }
    end
    
  end
end
