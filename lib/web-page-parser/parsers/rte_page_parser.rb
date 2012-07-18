module WebPageParser
  class RtePageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new("(www\.)?rte\.ie/[a-z-]+/[0-9]{4}/[0-9]{4}/[a-z-].[a-z-]{4}")
    INVALID_URL_RE = ORegexp.new("/cartoon/|/commentisfree/poll/|/video/[0-9]+|/gallery/[0-9]+|/poll/[0-9]+")

    def self.can_parse?(options)
      url = options[:url].split('#').first
      return nil if INVALID_URL_RE.match(url)
      URL_RE.match(url)
    end
    
    def self.create(options = {})
      RtePageParserV1.new(options)
    end
  end

  # BbcNewsPageParserV1 parses BBC News web pages exactly like the
  # old News Sniffer BbcNewsPage class did.  This should only ever
  # be used for backwards compatability with News Sniffer and is
  # never supplied for use by a factory.
  class RtePageParserV1 < WebPageParser::BaseParser
    ICONV = nil
    TITLE_RE = ORegexp.new('<meta name="DC.title" scheme="DCTERMS.URI" content="(.*)"', 'i')
    DATE_RE = ORegexp.new('<meta name="datemodified" content="(.*)"', 'i')
    CONTENT_RE = ORegexp.new('"storyBody">(.*?)<div id="user-options-bottom">', 'm')

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
