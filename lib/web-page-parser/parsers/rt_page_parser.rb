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
      RTPageParserV2.new(options)
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
      return @date if @date
      if (span_date = html_doc.at_css('span.date_article-header'))
        @date = DateTime.parse(span_date.text) rescue nil
      elsif (date_meta = html_doc.at_css('meta[name=published_time_telegram]'))
        @date = DateTime.parse(date_meta['content']) rescue nil
      elsif (div_date = html_doc.at_css('div.article time.date:first'))
        @date = DateTime.parse(div_date.text.strip)
      end
      @date
    end
  end

  # RTPageParserV2 parses RT web pages using html parsing.
  class RTPageParserV2 < RTPageParserV1
    def content
      return @content if @content
      article_summary = html_doc.css('div.article__summary')
      @content = []
      @content << article_summary.text.strip if article_summary
      article_text = html_doc.css('div.article__text')
      article_text.xpath('.//p | .//h2 | .//h3').each do |n|
        @content << n.text.strip
      end
      @content
    end
  end
end
