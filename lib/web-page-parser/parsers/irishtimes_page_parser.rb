module WebPageParser
  class IrishtimesPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new("(www\.)?irishtimes\.com/[a-z-]+/[a-z-]+/[0-9]{4}/[0-9]{4}/[0-9]+.[a-z-]{4}")

    INVALID_URL_RE = ORegexp.new("sport|comment")

    def self.can_parse?(options)
      url = options[:url].split('#').first
      return nil if INVALID_URL_RE.match(url)
      URL_RE.match(url)
    end
    
    def self.create(options = {})
      IrishtimesPageParserV1.new(options)
    end
  end

  class IrishtimesPageParserV1 < WebPageParser::BaseParser
    ICONV = nil
    TITLE_RE = ORegexp.new('<h1>(.+?)</h1>')
    DATE_RE = ORegexp.new('<meta name="datemodified" content="(.*)"', 'i')
    CONTENT_RE = ORegexp.new('class="left-column">(.*?)<div class="right-column">', 'm')
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
