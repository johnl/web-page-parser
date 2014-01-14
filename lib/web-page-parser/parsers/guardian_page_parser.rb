module WebPageParser
  class GuardianPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new("(www\.)?(the)?guardian\.(co\.uk|com)/[a-z-]+(/[a-z-]+)?/[0-9]{4}/[a-z]{3}/[0-9]{1,2}/[a-z-]{5,200}$")
    INVALID_URL_RE = ORegexp.new("/cartoon/|/commentisfree/poll/|/video/[0-9]+|/gallery/[0-9]+|/poll/[0-9]+")
    def self.can_parse?(options)
      url = options[:url].split('#').first
      return nil if INVALID_URL_RE.match(url)
      URL_RE.match(url)
    end
    
    def self.create(options = {})
      GuardianPageParserV1.new(options)
    end
  end

  # BbcNewsPageParserV1 parses BBC News web pages exactly like the
  # old News Sniffer BbcNewsPage class did.  This should only ever
  # be used for backwards compatability with News Sniffer and is
  # never supplied for use by a factory.
  class GuardianPageParserV1 < WebPageParser::BaseRegexpParser
    TITLE_RE = ORegexp.new('<meta property="og:title" content="(.*)"', 'i')
    DATE_RE = ORegexp.new('<meta property="article:published_time" content="(.*)"', 'i')
    CONTENT_RE = ORegexp.new('article-body-blocks">(.*?)<div id="related"', 'm')
    STRIP_TAGS_RE = ORegexp.new('</?(a|span|div|img|tr|td|!--|table)[^>]*>','i')
    STRIP_SCRIPTS_RE = ORegexp.new('<script[^>]*>.*?</script>','i')
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
      @content = STRIP_SCRIPTS_RE.gsub(@content, '')
      @content = @content.scan(PARA_RE).collect { |a| a[1] }
    end

    def filter_url(url)
      url.to_s.gsub("www.guprod.gnl", "www.guardian.co.uk") # some wierd guardian problem with some older articles
    end
    
  end
end
