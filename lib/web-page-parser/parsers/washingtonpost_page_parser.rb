module WebPageParser
  class WashingtonPostPageParserFactory < WebPageParser::ParserFactory
    URL_RE = ORegexp.new('www\.washingtonpost\.com/.*_story\.html')
    def self.can_parse?(options)
      url = options[:url].split('#').first
      URL_RE.match(url)
    end

    def self.create(options = {})
      WashingtonPostPageParserV1.new(options)
    end
  end

  # WashingtonPostPageParserV1 parses washpo web pages using html
  # parsing.
  class WashingtonPostPageParserV1 < WebPageParser::BaseParser
    require 'nokogiri'

    def html_doc
      @html_document ||= Nokogiri::HTML(page)
    end

    def title
      @title ||= html_doc.css('h1[property="dc.title"]').text.strip
    end

    def content
      return @content if @content
      story_body = html_doc.css('div.article_body *').select do |e|
        e.name == 'p'
      end
      story_body.collect { |p| p = p.text.strip ; p.empty? ? nil : p }.compact
    end

    def date
      return @date if @date
      # date in url is best source of first published date
      @date = DateTime.parse(url.scan(/[0-9]{4}\/[0-9]{2}\/[0-9]{2}/).first.to_s) rescue nil
      return @date if @date
      # failing that, get DC.date.issued which is actually last updated
      if date_meta = html_doc.at_css('meta[name="DC.date.issued"]')
        @date = DateTime.parse(date_meta['content']) rescue nil
      end
      @date
    end
  end
end
