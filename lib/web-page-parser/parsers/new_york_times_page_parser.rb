module WebPageParser
  class NewYorkTimesPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new("www\.nytimes\.com/[0-9]{4}/[0-9]{2}/[0-9]{2}/.+")
    INVALID_URL_RE = ORegexp.new("/cartoon/")
    def self.can_parse?(options)
      return nil if INVALID_URL_RE.match(options[:url])
      URL_RE.match(options[:url])
    end
    
    def self.create(options = {})
      NewYorkTimesPageParserV2.new(options)
    end
  end

  # NewYorkTimesPageParserV1 parses New York Times web pages up to January 2014
  class NewYorkTimesPageParserV1 < WebPageParser::BaseRegexpParser
    TITLE_RE = ORegexp.new('<nyt_headline [^>]*>(.*)</nyt_headline>', 'i')
    DATE_RE = ORegexp.new('<meta name="dat" content="(.*)"', 'i')
    CONTENT_RE = ORegexp.new('<nyt_text[^>]*>(.*)</nyt_text', 'mi')
    STRIP_TAGS_RE = ORegexp.new('</?(a|strong|span|div|img|tr|td|!--|table|ul|li)[^>]*>','i')
    PARA_RE = Regexp.new('<(p)[^>]*>(.*?)<\/\1>', 'i')
    STRIP_INLINE_BLOCK = ORegexp.new('<div class="articleInline.*<div class="articleBody[^>]*>', 'm')

    # We want to modify the url to request multi-page articles all in one request
    def retrieve_page
      return nil unless url
      spurl = url
      spurl << (spurl.include?("?") ? "&" : "?")
      spurl << "pagewanted=all"
      p = super(spurl)
      # If it fails, reset the session and try one more time
      unless retreive_successful?(p)
        self.class.retrieve_session ||= WebPageParser::HTTP::Session.new
        p = super(spurl)
      end
      if retreive_successful?(p)
        p
      else
        raise RetrieveError, "Blocked by NYT paywall"
      end
    end

    private

    def retreive_successful?(page)
      if page and page.curl
        page.curl.header_str.scan(/^Location: .*/).grep(/myaccount.nytimes.com/).empty?
      else
        false
      end
    end

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

  # NewYorkTimesPageParserV2 parses New York Times web pages,
  # including the new format change in Janurary 2014
  class NewYorkTimesPageParserV2 < WebPageParser::BaseParser
    require 'nokogiri'

    def html_doc
      @html_document ||= Nokogiri::HTML(page)
    end

    def title
      @title ||= html_doc.css('h1[itemprop=headline]').text.strip
    end

    def content
      return @content if @content
      @content = []
      html_doc.css('article#story div.StoryBodyCompanionColumn > div > p, article#story div.StoryBodyCompanionColumn > div > ul > li > p').each do |p|
        @content << p.text.strip
      end
      @content
    end

    def date
      return @date if @date
      if date_meta = html_doc.at_css('meta[property="article:published"]')
        @date = DateTime.parse(date_meta['content']) rescue nil
      end
      @date
    end
  end
end
