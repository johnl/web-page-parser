module WebPageParser
  class IndependentPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new("www.independent.co.uk/news/.*[0-9]+.html")
    INVALID_URL_RE = ORegexp.new("www.independent.co.uk/news/pictures")
    def self.can_parse?(options)
      return nil if INVALID_URL_RE.match(options[:url])
      URL_RE.match(options[:url])
    end

    def self.create(options = {})
      IndependentPageParserV1.new(options)
    end
  end

  # IndependentPageParserV1 parses Independent news web pages,
  class IndependentPageParserV1 < WebPageParser::BaseParser
    require 'nokogiri'

    # Independent articles have a guid in the url (as of Jan 2014, a
    # seven digit integer at the end of the url before the html extension)
    def guid_from_url
      # get the last large number from the url, if there is one
      url.to_s.scan(/[0-9]{6,12}/).last
    end

    def html_doc
      @html_document ||= Nokogiri::HTML(page)
    end

    def title
      @title ||= html_doc.css('div#main h1.title').text.strip
    end

    def content
      return @content if @content
      content = []
      story_body = html_doc.css('div.articleContent p')
      story_body.each do |p|
        p.search('script,object').remove
        p = p.text
        content << p.strip.gsub(/\n+/,' ') if p
      end
      @content = content.select { |p| !p.empty? }
    end

    def date
      return @date if @date
      if date_meta = html_doc.at_css('meta[property="article:published_time"]')
        @date = DateTime.parse(date_meta['content']) rescue nil
      end
      @date
    end

  end

end
