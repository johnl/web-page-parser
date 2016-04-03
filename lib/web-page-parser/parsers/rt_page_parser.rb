module WebPageParser
  class RTPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new("(www\.)?rt\.com/[^/]+/[0-9]+-.*$")
    INVALID_URL_RE = ORegexp.new("/(in-vision|in-motion)/")
    def self.can_parse?(options)
      url = options[:url].split('#').first
      return nil if INVALID_URL_RE.match(url)
      URL_RE.match(url)
    end

    def self.create(options = {})
      RTPageParserV1.new(options)
    end
  end

  # RTPageParserV1 parses RT web pages using html parsing.
  class RTPageParserV1 < WebPageParser::BaseParser
    require 'nokogiri'

    def html_doc
      @html_document ||= Nokogiri::HTML(page)
    end

    def title
      @title ||= html_doc.css('h1.article__heading').text.strip
    end

    def content
      return @content if @content
      story_summary = html_doc.css('div.article__summary').text.strip
      story_body = html_doc.css('div.article__text > *').select do |e|
        e.name == 'p' or e.name == 'h2' or e.name == 'h3'
      end
      story_body.collect! { |p| p.text.empty? ? nil : p.text.strip }.compact
      story_body.unshift story_summary unless story_summary.empty?
      story_body
    end

    def date
      @date ||= DateTime.parse(html_doc.at_css('div.article time.date:first').text.strip)
    end

    def filter_url(url)
      # some wierd guardian problem with some older articles
      url.to_s.gsub("www.guprod.gnl", "www.guardian.co.uk") 
    end
  end

end
